import Swinject
import ToolKit
import UIKit

struct ServicesAssembly: Assembly {

    func assemble(container: Container) {
        assembleTransientDependencies(container: container)
    }

    private func assembleTransientDependencies(container: Container) {
        container
            .register(Router.self) { _, navigationController in
                RouterImpl(navigationController: navigationController)
            }
            .inObjectScope(.transient)
    }
}
