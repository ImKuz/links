import ComposableArchitecture
import Models
import ToolKit
import LinkItemActions

// MARK: - State

struct CatalogRowState: Equatable, Identifiable {
    let id: String
    let title: String?
    let contentPreview: String?
}

// MARK: - Action

public enum CatalogRowAction: Equatable {
    case linkItemAction(LinkItemAction)
    case tap
}
