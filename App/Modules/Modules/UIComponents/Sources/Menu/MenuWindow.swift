import UIKit

final class MenuWindow: UIWindow {

    // needed because just setting the level on iOS 11+ to be more than the keyboard does not work for some reason
    override var windowLevel: UIWindow.Level {
        get { UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude - 1) }
        set { }
    }
}
