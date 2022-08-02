import GRPC
import NIO
import Contracts
import Models
import ToolKit
import Combine

protocol CatalogSourceProviderDelegate: AnyObject {
    func providerRequestsData() -> AnyPublisher<[LinkItem], AppError>
}

final class CatalogSourceProvider: Catalog_SourceProvider {

    // MARK: - Properties

    var interceptors: Catalog_SourceServerInterceptorFactoryProtocol?

    weak var delegate: CatalogSourceProviderDelegate?

    // MARK: - Private properties

    private var cancellables = [AnyCancellable]()
    private let updateEventsPublisher: AnyPublisher<Void, Never>
    private var catalogSubject = PassthroughSubject<Catalog_LinkItemsList, AppError>()
    private var contexts = [StreamingResponseCallContext<Catalog_LinkItemsList>]()

    // MARK: - Init

    init(updateEventsPublisher: AnyPublisher<Void, Never>) {
        self.updateEventsPublisher = updateEventsPublisher
        setupUpdatesBinding()
    }

    deinit {
        cancel()
    }

    // MARK: - Internal methods

    func cancel() {
        contexts.forEach {
            $0.statusPromise.completeWith(.success(.ok))
        }
        contexts = []
    }

    // MARK: - Catalog_SourceProvider

    func fetch(
        request: Catalog_Empty,
        context: StreamingResponseCallContext<Catalog_LinkItemsList>
    ) -> EventLoopFuture<GRPCStatus> {
        contexts.append(context)
        fillContextWithInitialData(context: context)
        return context.eventLoop.makePromise(of: GRPCStatus.self).futureResult
    }

    // MARK: - Private methods

    private func fillContextWithInitialData(
        context: StreamingResponseCallContext<Catalog_LinkItemsList>
    ) {
        getCurrentItems()
            .sink(
                receiveCompletion: { [weak context] completion in
                    if case .failure = completion {
                        context?.statusPromise.completeWith(.failure(GRPCStatus.processingError))
                    }
                },
                receiveValue: { [weak context] in
                    _ = context?.sendResponse($0)
                }
            )
            .store(in: &cancellables)
    }

    private func setupUpdatesBinding() {
        updateEventsPublisher
            .setFailureType(to: AppError.self)
            .flatMap { [weak self] _ -> AnyPublisher<[LinkItem], AppError> in
                guard let delegate = self?.delegate else { return Empty().eraseToAnyPublisher() }
                return delegate.providerRequestsData()
            }
            .map { Self.mapItems($0) }
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    defer { self.contexts = [] }

                    if case .failure = completion {
                        self.contexts.forEach {
                            $0.statusPromise.completeWith(.failure(GRPCStatus.processingError))
                        }
                    }
                },
                receiveValue: { [weak self] catalog in
                    guard let self = self else { return }
                    self.contexts.forEach {
                        _ = $0.sendResponse(catalog)
                    }
                }
            )
            .store(in: &cancellables)
    }

    private func getCurrentItems() -> AnyPublisher<Catalog_LinkItemsList, AppError> {
        guard let delegate = delegate else { return Empty().eraseToAnyPublisher() }

        return delegate
            .providerRequestsData()
            .map { Self.mapItems($0) }
            .eraseToAnyPublisher()
    }

    private static func mapItems(_ items: [LinkItem]) -> Catalog_LinkItemsList {
        return Catalog_LinkItemsList.with {
            $0.items = items.map { item in
                Catalog_LinkItem.with {
                    $0.id = item.id
                    $0.name = item.name
                    $0.urlString = item.urlString
                }
            }
        }
    }
}
