import Combine
import ToolKit
import Models
import CatalogSource
import SharedHelpers
import FeatureSupport
import UIKit

public protocol LinkItemActionsHandler {

    func handle(
        _ actionWithData: LinkItemAction.WithData
    ) -> AnyPublisher<LinkItemAction.WithData, AppError>
}

final class LinkItemActionsHandlerImpl: LinkItemActionsHandler {

    private let catalogSource: CatalogSource
    private let urlOpener: URLOpener
    private let pasteboard: UIPasteboard
    private let router: Router
    private let featureResolver: FeatureResolver

    private var cancellables = [AnyCancellable]()

    // MARK: - Init

    init(
        catalogSource: CatalogSource,
        urlOpener: URLOpener,
        pasteboard: UIPasteboard = .general,
        router: Router,
        featureResolver: FeatureResolver
    ) {
        self.catalogSource = catalogSource
        self.urlOpener = urlOpener
        self.pasteboard = pasteboard
        self.router = router
        self.featureResolver = featureResolver
    }

    // MARK: - LinkItemActionsHandler

    func handle(
        _ actionWithData: LinkItemAction.WithData
    ) -> AnyPublisher<LinkItemAction.WithData, AppError> {
        let itemId = actionWithData.data.itemId

        // TODO: Handle errors
        return catalogSource
            .fetchItem(itemId: itemId)
            .replaceError(with: nil)
            .withUnretained(self)
            .flatMap { ref, item -> AnyPublisher<Void, AppError> in
                switch actionWithData.action {
                case .open:
                    guard let urlString = item?.urlString else { return Self.failure("Unable to fetch item") }
                    return ref.urlOpener.open(urlString)

                case .edit:
                    guard let item = item else { return Self.failure("Unable to fetch item") }

                    return Future<Void, AppError> { [weak self] promise in
                        guard let self = self else { return }

                        DispatchQueue.main.async {
                            let editLinkFeature = ref.featureResolver.resolve(
                                feature: EditLinkFeatureInterface.self,
                                input: .init(
                                    catalogSource: ref.catalogSource,
                                    item: item,
                                    router: ref.router
                                )
                            )

                            ref.router.presentView(view: editLinkFeature.view)

                            editLinkFeature
                                .onFinishPublisher
                                .sink {
                                    promise(.success(()))
                                }
                                .store(in: &self.cancellables)
                        }
                    }
                    .eraseToAnyPublisher()

                case .delete:
                    return ref.catalogSource.delete(itemId: itemId)

                case .copy:
                    guard let urlString = item?.urlString else { return Self.failure("Unable to fetch item") }

                    ref.pasteboard.string = urlString

                    return Just(())
                        .setFailureType(to: AppError.self)
                        .eraseToAnyPublisher()

                case .addToFavorites:
                    return ref.catalogSource.setIsFavorite(id: itemId, isFavorite: true)
                case .removeFormFavorties:
                    return ref.catalogSource.setIsFavorite(id: itemId, isFavorite: false)
                }
            }
            .map { actionWithData }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func isItemPersisted(id: LinkItem.ID) -> AnyPublisher<Bool, AppError> {
        guard catalogSource.isPersistable else {
            return Just(false)
                .setFailureType(to: AppError.self)
                .eraseToAnyPublisher()
        }

        return catalogSource.contains(itemId: id)
    }

    private static func failure(_ message: String) -> AnyPublisher<Void, AppError> {
        Fail(error: AppError.common(description: message)).eraseToAnyPublisher()
    }
}
