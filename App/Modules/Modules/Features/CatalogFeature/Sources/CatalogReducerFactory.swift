import ComposableArchitecture
import IdentifiedCollections
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
                        .read()
                        .receive(on: DispatchQueue.main)
                        .catchToEffect(CatalogAction.itemsUpdated)
                case .addItemTap:
                    return env
                        .showForm()
                        .cancellable(id: ID.showForm, cancelInFlight: true)
                case let .itemsUpdated(.success(items)):
                    state.items = items
                case let .itemsUpdated(.failure(error)):
                    print(error)
                    return .none
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
        env: CatalogEnv
    ) -> Effect<CatalogAction, Never> {
        guard let index = state.items.index(id: itemId) else { return .none }

        switch action {
        case .onTap:
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
        case .onDelete:
            let temp = state.items.remove(at: index)

            return env
                .delete(temp)
                .receive(on: DispatchQueue.main)
                .fireAndForget()
        }
    }
}
