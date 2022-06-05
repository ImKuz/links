import GRPC
import NIO
import Contracts
import Models
import ToolKit
import Combine

protocol CatalogSourceProviderDelegate: AnyObject {
    func providerRequestsData() -> AnyPublisher<[CatalogItem], AppError>
}

final class CatalogSourceProvider: Catalog_SourceProvider {

    // MARK: - Properties

    var interceptors: Catalog_SourceServerInterceptorFactoryProtocol?
    weak var delegate: CatalogSourceProviderDelegate?

    // MARK: - Private properties

    private var fetchCancellable: AnyCancellable?

    // MARK: - Internal methods

    func cancel() {
        fetchCancellable?.cancel()
        fetchCancellable = nil
    }

    // MARK: - Catalog_SourceProvider

    func fetch(request: Catalog_Empty, context: StatusOnlyCallContext) -> EventLoopFuture<Catalog_Catalog> {
        guard let delegate = delegate else {
            return context
                .eventLoop
                .makeFailedFuture(
                    AppError.common(description: "Unable to fetch data")
                )
        }

        let promise = context.eventLoop.makePromise(of: Catalog_Catalog.self)

        fetchCancellable = delegate
            .providerRequestsData()
            .sink(
                receiveCompletion: {
                    if case let .failure(error) = $0 {
                        promise.completeWith(.failure(error))
                    }
                },
                receiveValue: {
                    let catalog = Self.mapItems($0)
                    promise.completeWith(.success(catalog))
                }
            )

        return promise.futureResult
    }

    private static func mapItems(_ items: [CatalogItem]) -> Catalog_Catalog {
        let items = items.map { item -> Catalog_Item in
            let kind: Catalog_Item.OneOf_Kind

            switch item.content {
            case let .link(url):
                kind = .link(.with {
                    $0.id = item.id
                    $0.name = item.name
                    $0.link = url.absoluteString
                })
            case let .text(text):
                kind = .snippet(.with {
                    $0.id = item.id
                    $0.name = item.name
                    $0.content = text
                })
            }

            return Catalog_Item.with {
                $0.kind = kind
            }
        }

        return .with {
            $0.items = items
        }
    }
}
