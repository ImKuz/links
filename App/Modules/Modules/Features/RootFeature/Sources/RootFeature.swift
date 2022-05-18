import ComposableArchitecture
import ToolKit
import Foundation
import SharedEnv
import Models

// MARK: - State

struct RootState: Equatable {
    var remoteSourceData: RemoteSourceData
    let tabs: [Tab]
}

// MARK: - Action

enum RootAction: Equatable {

}

// MARK: - Enviroment

struct RootEnv {

}

// MARK: - Reducer

typealias RootReducerType = Reducer<RootState, RootAction, SystemEnv<RootEnv>>
