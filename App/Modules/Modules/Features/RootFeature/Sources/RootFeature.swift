import ComposableArchitecture
import ToolKit
import Foundation
import Models

// MARK: - State

struct RootState: Equatable {
    var selectedTab = 0
    let tabs: [Tab]
}

// MARK: - Action

enum RootAction: Equatable {
    case tabChanged(Int)
}

// MARK: - Enviroment

struct RootEnv {

}

// MARK: - Reducer

let rootReducer = Reducer<RootState, RootAction, RootEnv> { state, action, env in
    switch action {
    case let .tabChanged(index):
        state.selectedTab = index
        return .none
    }
}
