import ComposableArchitecture
import Models
import ToolKit

// MARK: - State

struct CatalogRowState: Hashable {

    enum Icon: String {
        case link = "link"
        case text = "textformat"
    }

    let title: String?
    let content: String?
    let icon: Icon
}

// MARK: - Action

public enum CatalogRowAction: Equatable {
    case onTap
    case onDelete
}

// MARK: - Reducer

let catalogRowReducer = Reducer<CatalogItem, CatalogRowAction, Void> { _,_,_ in .none }
