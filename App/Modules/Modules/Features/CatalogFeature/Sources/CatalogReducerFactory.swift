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
                case .viewDidLoad:
                    return env
                        .environment
                        .read()
                        .receive(on: env.mainQueue())
                        .catchToEffect(CatalogAction.itemsUpdated)
                case .addItemTap:
                    return env
                        .environment
                        .showForm()
                        .cancellable(id: ID.showForm)
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
                case .dismissPresentedView:
                    return env
                        .environment
                        .dismissPresetnedView()
                        .flatMap { 
                            Effect<CatalogAction, Never>.cancel(id: ID.showForm)
                        }
                        .eraseToEffect()
                case let .rowAction(id, action):
                    guard let index = state.items.index(id: id) else { return .none }

                    switch action {
                    case .onTap:
                        let content = state.items[index].content
                        return env
                            .environment
                            .handleContent(content)
                            .catchToEffect { [content] _ in
                                switch content {
                                case .text:
                                    return CatalogAction.titleMessage(text: "Copied to clipboard!")
                                case .link:
                                    return .none
                                }
                            }
                    case .onDelete:
                        let temp = state.items.remove(at: index)

                        return env
                            .environment
                            .delete(temp)
                            .receive(on: env.mainQueue())
                            .fireAndForget()
                    }
                case .none:
                    return .none
                }
                return .none
            }
        )
    }
}
