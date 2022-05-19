import ComposableArchitecture
import IdentifiedCollections
import SharedEnv
import Combine

struct CatalogReducerFactory {

    private enum ID {
        static let showForm = "showForm"
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
                case .updateData:
                    return env
                        .environment
                        .read()
                        .receive(on: env.mainQueue())
                        .catchToEffect(CatalogAction.itemsUpdated)
                case .addItemTap:
                    return env
                        .environment
                        .showForm()
                        .cancellable(id: ID.showForm, cancelInFlight: true)
                case let .itemsUpdated(.success(items)):
                    state.items = items
                case let .itemsUpdated(.failure(error)):
                    print(error)
                    return .none
                case let .moveItem(from, to):
                    return env
                        .environment
                        .move(from, to)
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
                        .environment
                        .dismissPresetnedView()
                        .eraseToEffect { .updateData }
                case let .rowAction(id, action):
                    return handleRowAction(
                        state: &state,
                        itemId: id,
                        action: action,
                        env: env
                    )
                }
                return .none
            }
        )
    }

    // MARK: - Row action

    private func handleRowAction(
        state: inout CatalogState,
        itemId: String,
        action: CatalogRowAction,
        env: SystemEnv<CatalogEnv>
    ) -> Effect<CatalogAction, Never> {
        guard let index = state.items.index(id: itemId) else { return .none }

        switch action {
        case .onTap:
            let content = state.items[index].content

            return env
                .environment
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
        case .onDelete:
            let temp = state.items.remove(at: index)

            return env
                .environment
                .delete(temp)
                .receive(on: env.mainQueue())
                .fireAndForget()
        }
    }
}
