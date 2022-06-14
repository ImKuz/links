import ComposableArchitecture
import Models
import ToolKit

// MARK: - State

struct CatalogRowState: Equatable {

    enum Icon: String {
        case link = "link"
        case text = "textformat"
    }

    let title: String?
    let content: String?
    let icon: Icon
    let actions: [CatalogState.RowMenuAction]
}

// MARK: - Action

public enum CatalogRowAction: Equatable {
    case copy
    case tap
    case delete
}

// MARK: - Reducer

let catalogRowReducer = Reducer<CatalogItem, CatalogRowAction, Void> { _,_,_ in .none }
