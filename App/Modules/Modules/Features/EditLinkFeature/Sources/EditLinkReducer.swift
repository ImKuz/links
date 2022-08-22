import ComposableArchitecture
import Combine
import UIKit

let editLinkReducer = EditLinkReducer { state, action, env in
    switch action {
    case let .changeName(name):
        state.name = name

    case let .changeUrlString(string):
        state.urlString = string
        state.urlStringComponents = .deconstructed(from: string)

    case let .changeQueryParamKey(key, index):
        state.urlStringComponents.queryParams[index].key = key
        state.urlString = state.urlStringComponents.constructUrlString()

    case let .changeQueryParamValue(value, index):
        state.urlStringComponents.queryParams[index].value = value
        state.urlString = state.urlStringComponents.constructUrlString()

    case let .expandQueryParamValue(index):
        return env
            .expandQueryItemValue(value: state.urlStringComponents.queryParams[index].value)
            .receive(on: DispatchQueue.main)
            .eraseToEffect { EditLinkAction.changeQueryParamValue(value: $0, index: index) }

    case let .deleteQueryParam(index):
        state.urlStringComponents.queryParams.remove(at: index)

    case .appendQueryParam:
        state.urlStringComponents.queryParams.append(.empty)

    case let .onLinkItemAction(action):
        return env
            .handle(action: action)
            .catchToEffect { .onLinkItemActionCompletion(result: $0) }

    case let .onLinkItemActionCompletion(result):
        switch result {
        case let .success(actionWithData):
            switch actionWithData.action {
            case .delete:
                env.close()
                return .none
            default:
                return .none
            }
        case let .failure(error):
            // TODO: Error handling
            return .none
        }

    case .open:
        return env
            .openLink(state: state)
            .fireAndForget()

    case .done:
        return env
            .save(state: state)
            .fireAndForget()
    }

    return .none
}

