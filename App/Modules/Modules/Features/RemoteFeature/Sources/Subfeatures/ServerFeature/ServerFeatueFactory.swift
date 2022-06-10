import ComposableArchitecture
import Swinject
import CatalogServer
import ToolKit
import UIKit

enum ServerFeatueFactory {

    static func make(
        router: Router,
        catalogServer: CatalogServer,
        onClose: (() -> ())?
    ) -> ServerView {
        let env = ServerEnvImpl(
            server: catalogServer,
            router: router,
            onClose: onClose
        )

        let store =  Store<ServerState, ServerAction>(
            initialState: .init(),
            reducer: serverReducer,
            environment: env
        )

        return ServerView(store: store)
    }
}
