import Swinject
import Database
import ToolKit
import UIKit

struct ServicesAssembly: Assembly {

    func assemble(container: Container) {
        assembleTransientDependencies(container: container)
        assembleServices(container: container)
    }

    private func assembleServices(container: Container) {
        container.register(DatabaseService.self) { _ in
            try! DatabaseServiceImpl()
        }
        .inObjectScope(.container)
    }

    private func assembleTransientDependencies(container: Container) {
        container
            .register(Router.self) { _, navigationController in
                RouterImpl(navigationController: navigationController)
            }
            .inObjectScope(.transient)
    }
}
