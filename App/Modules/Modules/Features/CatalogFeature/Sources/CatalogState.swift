import Foundation
import Models
import IdentifiedCollections
import UIKit

struct CatalogState: Equatable {

    var hasCloseButton: Bool
    var title: String
    var titleMessage: String? = nil
    var items: IdentifiedArrayOf<LinkItem> = []

    var leftButton: ButtonConfig? = nil
    var rightButton: ButtonConfig? = nil

    var canMoveItems = false
}
