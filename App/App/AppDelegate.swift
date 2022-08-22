import AppAssembler
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var assembler: AppAssembler?
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let assembler = AppAssemblerFactory.make()

        window = UIWindow()
        window?.rootViewController = assembler.assmble()
        window?.makeKeyAndVisible()
        self.assembler = assembler

        return true
    }
}

