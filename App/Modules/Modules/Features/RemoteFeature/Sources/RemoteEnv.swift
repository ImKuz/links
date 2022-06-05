import ToolKit

final class RemoteEnvImpl: RemoteEnv {

    private let router: Router

    init(router: Router) {
        self.router = router
    }
}
