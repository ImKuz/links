import ComposableArchitecture
import Models
import ToolKit
import LinkItemActions

// MARK: - Aliases

typealias EditLinkViewStore = ViewStore<EditLinkState, EditLinkAction>
typealias EditLinkReducer = Reducer<EditLinkState, EditLinkAction, EditLinkEnv>

// MARK: - State

struct EditLinkState: Equatable {

    enum ValidateableField: Hashable {
        case name
        case url
        case key(index: Int)
        case value(index: Int)
    }

    // MARK: Properties

    var itemId: String
    var name: String
    var urlStringComponents: URLStringComponents?
    var invalidFields = Set<ValidateableField>()

    var isFormValid: Bool { invalidFields.isEmpty }
    var queryParams: [QueryParam] { urlStringComponents?.queryParams ?? [] }
    var urlString: String { urlStringComponents?.constructUrlString() ?? "" }
}

// MARK: - Action

enum EditLinkAction: Equatable {
    case changeName(String)
    case changeUrlString(String)

    case changeQueryParamKey(key: String, index: Int)
    case changeQueryParamValue(value: String, index: Int)
    case expandQueryParamValue(index: Int)
    case deleteQueryParam(index: Int)
    case appendQueryParam
    case onLinkItemAction(action: LinkItemAction.WithData)
    case onLinkItemActionCompletion(result: Result<LinkItemAction.WithData, AppError>)
    case open
    case done
}

// MARK: - Enviroment

protocol EditLinkEnv: AnyObject {

    func validateState(_ state: EditLinkState) -> Effect<Set<EditLinkState.ValidateableField>, Never>
    func save(state: EditLinkState) -> Effect<Void, AppError>
    func close()
    func dismissPresetnedView()
    func followLink(state: EditLinkState) -> Effect<Void, AppError>
    func expandQueryItemValue(value: String) -> Effect<String, Never>
    func handle(action: LinkItemAction.WithData) -> Effect<LinkItemAction.WithData, AppError>
}
