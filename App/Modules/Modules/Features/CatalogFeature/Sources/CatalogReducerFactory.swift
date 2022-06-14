import ComposableArchitecture
import IdentifiedCollections
import Combine
import UIKit

struct CatalogReducerFactory {

    private enum ID {
        static let showForm = "showForm"
        static let updates = "updates"
    }

    func make() -> CatalogReducerType {
        CatalogReducerType.combine(
            catalogRowReducer.forEach(
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
                    return env
                        .subscribe()
                        .receive(on: DispatchQueue.main)
                        .catchToEffect(CatalogAction.itemsUpdated)
                        .cancellable(id: ID.updates)
                case .addItem:
                    return env
                        .showForm()
                        .cancellable(id: ID.showForm, cancelInFlight: true)
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
                }
            }
        )
    }

    // MARK: - Row action

    private func setupState(state: inout CatalogState, env: CatalogEnv) {
        state.canMoveItems = env.permissions.contains(.write)

        if env.permissions.contains(.write) {
            state.rightButton = .init(
                title: nil,
                systemImageName: "plus",
                action: .addItem
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

    private func handleRowAction(
        state: inout CatalogState,
        itemId: String,
        action: CatalogRowAction,
        env: CatalogEnv
    ) -> Effect<CatalogAction, Never> {
        guard let index = state.items.index(id: itemId) else { return .none }

        switch action {
        case .tap:
            let content = state.items[index].content

            return env
                .handleContent(content)
                .compactMap { [content] in
                    switch content {
                    case .text:
                        return CatalogAction.titleMessage(text: "Copied to clipboard!")
                    case .link:
                        return nil
                    }
                }
                .eraseToEffect()
        case .copy:
            let content = state.items[index].content

            let string: String = {
                switch content {
                case let .link(url):
                    return url.absoluteString
                case let .text(text):
                    return text
                }
            }()

            return env
                .copyContent(string)
                .eraseToEffect {
                    CatalogAction.titleMessage(text: "Copied to clipboard!")
                }
        case .delete:
            let temp = state.items.remove(at: index)

            return env
                .delete(temp)
                .receive(on: DispatchQueue.main)
                .fireAndForget()
        }
    }
}
