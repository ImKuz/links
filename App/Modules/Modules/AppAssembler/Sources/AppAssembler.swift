import UIKit
import ToolKit
import Swinject
import SharedInterfaces

public protocol AppAssembler: AnyObject {

    func assmble() -> UIViewController
}

final class AppAssemblerImpl: AppAssembler {

    private let container = Container()
    private var assmbler: Assembler?
    private var rootViewController: UINavigationController?
    private var rootRouter: Router?

    // MARK: - AppAssembler

    func assmble() -> UIViewController {
        assmbler = DIAssemblerFactory.make(container: container)
        makeRootViewController()
        makeRootRouter()
        instantiateRootFeature()

        guard let rootViewController = rootViewController else {
            fatalError("No root navigation controller")
        }

        return rootViewController
    }

    private func makeRootViewController() {
        let navigationController = UINavigationController()
        rootViewController = navigationController
        configureRootNavigationController()
    }

    private func makeRootRouter() {
        guard let rootViewController = rootViewController else {
            fatalError("No root navigation controller at the moment of root Router definition")
        }

        rootRouter = container.resolve(Router.self, argument: rootViewController)
        guard let rootRouter = rootRouter else { return }
        container.register(Router.self, name: "root") { _ in rootRouter }
    }

    private func instantiateRootFeature() {
        guard let view = container.resolve(RootFeatureInterface.self)?.view else {
            fatalError("RootFeature is not registered")
        }

        rootRouter?.pushToView(view: view, isAnimated: false)
    }

    private func configureRootNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .secondarySystemBackground

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        guard let rootViewController = rootViewController else { return }

        rootViewController.navigationBar.isHidden = true
    }
}
