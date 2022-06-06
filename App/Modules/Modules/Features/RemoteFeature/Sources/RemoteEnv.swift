import ToolKit
import ComposableArchitecture

final class RemoteEnvImpl: RemoteEnv {

    private let router: Router

    init(router: Router) {
        self.router = router
    }
}
