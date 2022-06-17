import Foundation
import Models
import IdentifiedCollections
import UIKit

struct CatalogState {

    var hasCloseButton: Bool
    var title: String
    var titleMessage: String? = nil
    var items: IdentifiedArrayOf<CatalogItem>

    var leftButton: ButtonConfig? = nil
    var rightButton: ButtonConfig? = nil

    var canMoveItems = false

    init(
        hasCloseButton: Bool,
        items: IdentifiedArrayOf<CatalogItem>,
        title: String
    ) {
        self.hasCloseButton = hasCloseButton
        self.title = title
        self.items = items
    }

    static func initial(hasCloseButton: Bool, title: String) -> Self {
        Self(
            hasCloseButton: hasCloseButton,
            items: [],
            title: title
        )
    }
}

// MARK: - Nested types

extension CatalogState {

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

    struct RowMenuAction: Equatable {

        let iconName: String
        let title: String
        let action: CatalogRowAction
        let isDestructive: Bool

        init(
            iconName: String,
            title: String,
            action: CatalogRowAction,
            isDestructive: Bool = false
        ) {
            self.iconName = iconName
            self.title = title
            self.action = action
            self.isDestructive = isDestructive
        }
    }
}

extension CatalogState: Equatable {

}
