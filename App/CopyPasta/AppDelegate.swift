import Swinject
import UIKit
import ToolKit
import SharedInterfaces
import AppAssembler

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let container = Container()
    private var assmbler: Assembler?
    private var rootViewController: UINavigationController?
    private var rootRouter: Router?

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        assmbler = AppAssemblerFactory.make(container: container)

        makeRootViewController()
        makeRootRouter()
        instantiateRootFeature()

        window = UIWindow()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        return true
    }

    private func makeRootViewController() {
        let navigationController = UINavigationController()
        rootViewController = navigationController
        configureRootNavigationController()
    }

    private func makeRootRouter() {
        guard let rootViewController = rootViewController else { return }

        rootRouter = container.resolve(Router.self, argument: rootViewController)

        guard let rootRouter = rootRouter else { return }

        container.register(Router.self, name: "root") { _ in
            rootRouter
        }
    }

    private func instantiateRootFeature() {
        guard let view = container.resolve(RootFeatureInterface.self)?.view else {
            fatalError("No rootView on didFinishLaunchingWithOptions")
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

