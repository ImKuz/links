import ComposableArchitecture
import Models
import ToolKit

// MARK: - State

struct CatalogRowState: Equatable, Identifiable {
    let id: String
    let title: String?
    let contentPreview: String?
    let actions: [RowMenuAction]
}

// MARK: - Action

public enum CatalogRowAction: Equatable {
    case copy
    case follow
    case edit
    case tap
    case delete
    case setIsFavorite(Bool)
}

// MARK: - Reducer

let catalogRowReducer = Reducer<LinkItem, CatalogRowAction, Void>.empty
