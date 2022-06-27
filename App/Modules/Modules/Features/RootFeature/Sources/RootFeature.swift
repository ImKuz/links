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

typealias RootReducerType = Reducer<RootState, RootAction, RootEnv>
