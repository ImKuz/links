import ComposableArchitecture
import ToolKit

// MARK: - Action

public enum CatalogRowAction: Equatable {
    case onTap
}

// MARK: - Reducer

let catalogRowReducer = Reducer<CatalogItem, CatalogRowAction, Void> { _,_,_ in .none }
