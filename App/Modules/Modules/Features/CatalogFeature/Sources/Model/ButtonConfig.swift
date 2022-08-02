import UIKit

struct ButtonConfig: Equatable {

    let title: String?
    let systemImageName: String?
    let action: CatalogAction
    let tintColor: UIColor

    init(
        title: String?,
        systemImageName: String?,
        action: CatalogAction,
        tintColor: UIColor = .systemBlue
    ) {
        self.title = title
        self.systemImageName = systemImageName
        self.action = action
        self.tintColor = tintColor
    }
}
