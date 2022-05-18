import ComposableArchitecture
import IdentifiedCollections
import SharedEnv

struct CatalogReducerFactory {

    func make() -> CatalogReducerType {
        CatalogReducerType.combine(
            catalogRowReducer.forEach(
                state: \.items,
                action: /CatalogAction.rowAction,
                environment: { _ in }
            ),
            Reducer { state, action, env in
                switch action {
                case .test:

                    let id = UUID().uuidString
                    let item = CatalogItem(id: id, name: id, content: .text("foo"))
                    state.items.insert(item, at: 0)

                    return env
                        .add(item)
                        .fireAndForget()

                case .noAction:

                    return .none

                case .onAppear:

                    return env
                        .read()
                        .receive(on: env.mainQueue())
                        .catchToEffect(CatalogAction.itemsUpdated)

                case let .itemsUpdated(.success(items)):

                    state.items = items

                case let .itemsUpdated(.failure(error)):

                    return .none

                case let .deleteRow(indexSet):

                    if let index = indexSet.first {
                        let item = state.items[index]
                        state.items.remove(at: index)

                        return env
                            .delete(item)
                            .receive(on: env.mainQueue())
                            .fireAndForget()
                    }

                case let .dropItemHandle(.failure(error)):

                    return .none

                case let .dropItemHandle(.success(target)):

                    let initialState = state.items

                    state.items.remove(target.item)
                    state.items.insert(target.item, at: target.index)

                    return env
                        .move(target.item, target.index)
                        .catchToEffect { result in
                            switch result {
                            case .failure:
                                return .discardEdit(initialState)
                            case .success:
                                return .noAction
                            }
                        }

                case let .prepareDropTarget(index, item):

                    return env
                        .prepareDropTarget(index, item)
                        .receive(on: env.mainQueue())
                        .catchToEffect(CatalogAction.dropItemHandle)

                case let .rowAction(id, action):

                    return .none

                case let .discardEdit(items):

                    state.items = items

                }

                return .none
            }
        )
    }
}
