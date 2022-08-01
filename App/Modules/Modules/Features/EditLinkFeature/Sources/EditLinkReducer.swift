import ComposableArchitecture
import Combine
import UIKit

let editLinkReducer = EditLinkReducer { state, action, env in
    switch action {
    case let .changeName(name):
        state.name = name
    case let .changeUrl(string):
        state.urlComponents = .init(string: string)
    case let .changeQueryItemName(name, index):
        state.urlComponents?.queryItems?[index].name = name
    case let .changeQueryItemValue(value, index):
        state.urlComponents?.queryItems?[index].value = value
    case let .expandQueryItemValue(index):
        guard let value = state.urlComponents?.queryItems?[index].value else { return .none }

        return env
            .expandQueryItemValue(value: value)
            .receive(on: DispatchQueue.main)
            .eraseToEffect { EditLinkAction.changeQueryItemValue(value: $0, index: index) }
    case let .deleteQueryItem(index):
        state.urlComponents?.queryItems?.remove(at: index)
    case .addQueryItem:
        if state.urlComponents?.queryItems == nil {
            state.urlComponents?.queryItems = []
        }

        state.urlComponents?.queryItems?.append(.init(name: "", value: ""))
    case .done:
        return .none
    case .delete:
        return .none
    case .copy:
        return .none
    case .follow:
        return .none
    }

    return .none
}

