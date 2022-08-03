import IdentifiedCollections
import ToolKit
import Models
import Combine
import CatalogClient
import SharedInterfaces

final class RemoteCatalogSource: CatalogSource, ConnectionObservable {

    let permissions: CatalogDataSourcePermissions = [.read, .favorites]

    private let client: CatalogClient
    private let favoritesCatalogSourceHelper: FavoritesCatalogSourceHelper
    private let bus: RemoteCatalogSourceDatabaseBus

    private var clientSubscription: AnyCancellable?

    var connectivityPublisher: AnyPublisher<ConnectionState, Never> {
        client.connectivityPublisher
    }

    init(
        client: CatalogClient,
        favoritesCatalogSourceHelper: FavoritesCatalogSourceHelper,
        bus: RemoteCatalogSourceDatabaseBus
    ) {
        self.client = client
        self.favoritesCatalogSourceHelper = favoritesCatalogSourceHelper
        self.bus = bus
    }

    private func bindClientUpdates() {
        bus.reset()
        client.disconnect()

        clientSubscription = client
            .subscribe()
            .map { IdentifiedArrayOf(uniqueElements: $0) }
            .sink(
                receiveCompletion: { [weak bus] in
                    if case let .failure(error) = $0 {
                        bus?.pass(error: error)
                    }
                },
                receiveValue: { [weak bus] in
                    bus?.pass(items: $0)
                }
            )
    }

    func subscribe() -> AnyPublisher<IdentifiedArrayOf<LinkItem>, AppError> {
        bindClientUpdates()

        return bus.output
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func setIsFavorite(item: LinkItem, isFavorite: Bool) -> AnyPublisher<Void, AppError> {
        favoritesCatalogSourceHelper
            .setIsFavorite(item: item, isFavorite: isFavorite)
            .handleEvents(receiveOutput: { [weak bus] _ in
                bus?.synchronizeState()
            })
            .eraseToAnyPublisher()
    }
}
