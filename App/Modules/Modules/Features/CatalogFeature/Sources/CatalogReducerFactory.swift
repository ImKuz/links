import ComposableArchitecture
import IdentifiedCollections
import Combine
import UIKit
import ToolKit
import Models

struct CatalogReducerFactory {

    private enum ID {
        static let showForm = "showForm"
        static let showErrorSheet = "showErrorSheet"
        static let updates = "updates"
        static let connectivity = "connectivity"
        static let appUpdates = "appUpdates"
    }

    func make() -> CatalogReducerType {
        CatalogReducerType.combine(
            Reducer<LinkItem, CatalogRowAction, Void>.empty.forEach(
                state: \.items,
                action: /CatalogAction.rowAction,
                environment: { _ in }
            ),
            Reducer { state, action, env in
                switch action {
                case .viewDidLoad:
                    setupState(state: &state, env: env)
                    return Effect(value: .suscribeToUpdates)

                case .suscribeToUpdates:
                    return suscribeToUpdates(env: env)

                case .applicationStateUpdated:
                    return env
                        .reloadCatalog()
                        .fireAndForget()

                case let .handleConnectionStateChange(connectionState):
                    switch connectionState {
                    case .failure:
                        state.rightButton = .init(
                            title: nil,
                            systemImageName: "exclamationmark.circle",
                            action: .connectionFailureInfo,
                            tintColor: .systemRed
                        )
                        return .none
                    case .connecting:
                        return .none
                    case .ok:
                        state.rightButton = nil
                        return .none
                    }

                case .connectionFailureInfo:
                    return env
                        .showConnectionErrorSheet()
                        .cancellable(id: ID.showErrorSheet, cancelInFlight: true)

                case .addLinkItem:
                    return env
                        .showEditLinkForm(item: nil)
                        .cancellable(id: ID.showForm, cancelInFlight: true)
                        .catchToEffect {
                            switch $0 {
                            case let .success(action):
                                return action
                            case let .failure(error):
                                return .handleError(error)
                            }
                        }

                case .close:
                    return env
                        .close()
                        .fireAndForget()

                case let .itemsUpdated(.success(items)):
                    state.items = items
                    return .none

                case let .itemsUpdated(.failure(error)):
                    return env
                        .showErrorAlert(error: error)
                        .eraseToEffect { CatalogAction.suscribeToUpdates }

                case let .moveItem(from, to):
                    return env
                        .move(from, to)
                        .receive(on: DispatchQueue.main)
                        .fireAndForget()

                case let .titleMessage(text):
                    state.titleMessage = text

                    return Just(())
                        .delay(for: .seconds(3), scheduler: RunLoop.main, options: .none)
                        .catchToEffect { [title = state.title] _ in
                            return CatalogAction.titleMessage(text: title)
                        }

                case .dismissAddItemForm:
                    return env
                        .dismissPresetnedView()
                        .fireAndForget()

                case let .rowAction(id, action):
                    return handleRowAction(
                        state: &state,
                        itemId: id,
                        action: action,
                        env: env
                    )
                    .catch { Effect(value: CatalogAction.handleError($0)) }
                    .eraseToEffect()
                case let .handleActionCompletion(action):
                    guard
                        case let .rowAction(_, rowAction) = action,
                        case let .linkItemAction(linkItemAction) = rowAction
                    else {
                        return .none
                    }

                    switch linkItemAction {
                    case .copy:
                        return Effect(value: .titleMessage(text: "Copied to clipboard!"))
                    case .edit:
                        return Effect(value: .dismissAddItemForm)
                    default:
                        return .none
                    }
                case .handleError:
                    // TODO: Error handling
                    return .none
                }
            }
        )
    }

    private func setupState(state: inout CatalogState, env: CatalogEnv) {
        state.canMoveItems = env.permissions.contains(.modify)

        if env.permissions.contains(.add) {
            state.rightButton = .init(
                title: nil,
                systemImageName: "plus",
                action: .addLinkItem
            )
        }

        if state.hasCloseButton {
            state.leftButton = .init(
                title: "Close",
                systemImageName: "xmark",
                action: .close
            )
        }
    }

    private func suscribeToUpdates(env: CatalogEnv) -> Effect<CatalogAction, Never> {
        let itemsUpdates = env
            .subscribeToCatalogUpdates()
            .receive(on: DispatchQueue.main)
            .catchToEffect(CatalogAction.itemsUpdated)
            .cancellable(id: ID.updates)

        let connectivityUpdates = env
            .observeConnectivity()
            .receive(on: DispatchQueue.main)
            .eraseToEffect(CatalogAction.handleConnectionStateChange)
            .cancellable(id: ID.connectivity)

        let appUpdates = env
            .observeAppStateChanges()
            .receive(on: DispatchQueue.main)
            .eraseToEffect { CatalogAction.applicationStateUpdated }
            .cancellable(id: ID.appUpdates)

        return Effect.merge(
            itemsUpdates,
            connectivityUpdates,
            appUpdates
        )
    }

    // MARK: - Row action

    private func handleRowAction(
        state: inout CatalogState,
        itemId: String,
        action: CatalogRowAction,
        env: CatalogEnv
    ) -> Effect<CatalogAction, AppError> {
        guard let index = state.items.index(id: itemId) else { return .none }
        let item = state.items[index]

        switch action {
        case .tap:
            return Effect(value: .rowAction(id: itemId, action: env.tapAction))
        case let .linkItemAction(linkItemAction):
            return env.handleLinkItemAction(linkItemAction, item: item)
        }
    }
}
