import ComposableArchitecture
import Combine
import UIKit

let editLinkReducer = EditLinkReducer { state, action, env in
    switch action {
    case let .changeName(name):
        state.name = name
    case let .changeUrlString(string):
        state.urlStringComponents = .deconstructed(from: string)
    case let .changeQueryParamKey(key, index):
        state.urlStringComponents?.queryParams[index].key = key
    case let .changeQueryParamValue(value, index):
        state.urlStringComponents?.queryParams[index].value = value
    case let .expandQueryParamValue(index):
        guard let value = state.urlStringComponents?.queryParams[index].value else { return .none }

        return env
            .expandQueryItemValue(value: value)
            .receive(on: DispatchQueue.main)
            .eraseToEffect { EditLinkAction.changeQueryParamValue(value: $0, index: index) }
    case let .deleteQueryParam(index):
        state.urlStringComponents?.queryParams.remove(at: index)
    case .appendQueryItem:
        state.urlStringComponents?.queryParams.append(.empty)
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

