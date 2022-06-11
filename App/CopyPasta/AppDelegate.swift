import Swinject
import UIKit
import ToolKit
import SharedInterfaces

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
        assmbler = AppAssemblerFactory(rootContainer: container).assembler()
        let navigationController = UINavigationController()
        rootViewController = navigationController
        configureRootNavigationController()

        rootRouter = container.resolve(Router.self, argument: navigationController)
        registerRootRouter()
        let rootViewInterface = container.resolve(RootFeatureInterface.self)

        guard let view = rootViewInterface?.view else {
            fatalError("No rootView on didFinishLaunchingWithOptions")
        }

        rootRouter?.pushToView(view: view, isAnimated: false)

        window = UIWindow()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        return true
    }

    private func registerRootRouter() {
        guard let rootRouter = rootRouter else { return }

        container.register(Router.self, name: "root") { _ in
            rootRouter
        }
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

