import SharedInterfaces
import SwiftUI
import Swinject
import Models

protocol RootTabViewsProvider {

    func view(for tabType: TabType) -> AnyView?
}

final class RootTabViewsProviderImpl: RootTabViewsProvider {

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    // MARK: - RootTabViewsProvider

    func view(for tabType: TabType) -> AnyView? {
        switch tabType {
        case .favorites:
            fatalError("Not implemented")
        case .local:
            return container.resolve(CatalogFeatureInterface.self, name: "local")!.view
        case .remote:
            fatalError("Not implemented")
        }
    }
}
