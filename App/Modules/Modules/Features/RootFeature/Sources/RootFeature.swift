import ComposableArchitecture
import ToolKit
import Foundation
import Models

// MARK: - State

struct RootState: Equatable {
    let tabs: [Tab]
}

// MARK: - Action

enum RootAction: Equatable {

}

// MARK: - Enviroment

struct RootEnv {

}

// MARK: - Reducer

typealias RootReducerType = Reducer<RootState, RootAction, RootEnv>
