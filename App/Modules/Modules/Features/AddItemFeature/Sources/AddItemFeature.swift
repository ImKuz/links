import ComposableArchitecture
import Models
import ToolKit

// MARK: - State

struct AddItemState: Equatable {

    enum ContentOption: String {
        case text = "Text"
        case link = "Link"
    }

    @BindableState var title: String = ""
    @BindableState var contentText: String = ""
    @BindableState var selectedOption = 0

    let contentOptions: [ContentOption]
    var isFormValid: Bool

    static var initial: Self {
        .init(
            contentOptions: [.text, .link],
            isFormValid: false
        )
    }
}

// MARK: - Action

enum AddItemAction: BindableAction, Equatable {
    case validationResult(Result<Bool, Never>)
    case binding(BindingAction<AddItemState>)
    case onCancel
    case onDone
}

// MARK: - Enviroment

protocol AddItemEnv: AnyObject {

    func validateState(_ state: AddItemState) -> Effect<Bool, Never>
    func cancel() -> Effect<Void, Never>
    func done(state: AddItemState) -> Effect<Void, AppError>
}

// MARK: - Reducer

let addItemReducer = Reducer<AddItemState, AddItemAction, AddItemEnv> { state, action, env in
    switch action {
    case let .validationResult(.success(isValid)):
        state.isFormValid = isValid
    case .binding:
        return env
            .validateState(state)
            .catchToEffect(AddItemAction.validationResult)
    case .onCancel:
        return env
            .cancel()
            .fireAndForget()
    case .onDone:
        return env
            .done(state: state)
            .eraseToEffect()
            .receive(on: DispatchQueue.main)
            .catchToEffect { _ in
                // TODO: Error handling
                .onCancel
            }
    default:
        return .none
    }

    return .none
}
.binding()
