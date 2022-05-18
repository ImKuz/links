import Swinject
import Database
import ToolKit
import UIKit

final class ServicesAssembly: Assembly {

    func assemble(container: Container) {
        assembleTransientDependencies(container: container)
        assembleServices(container: container)
    }

    private func assembleServices(container: Container) {
        container.register(DatabaseService.self) { _ in
            try! DatabaseServiceImpl()
        }
    }

    private func assembleTransientDependencies(container: Container) {
        container
            .register(Router.self) { _, navigationController in
                RouterImpl(navigationController: navigationController)
            }
            .inObjectScope(.transient)
    }
}
