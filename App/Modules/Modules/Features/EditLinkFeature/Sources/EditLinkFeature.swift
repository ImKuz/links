import ComposableArchitecture
import Models
import ToolKit

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

    var name: String
    var urlComponents: URLComponents?
    var invalidFields = Set<ValidateableField>()

    var isFormValid: Bool { invalidFields.isEmpty }
    var queryItems: [URLQueryItem] { urlComponents?.queryItems ?? [] }
    var urlString: String { urlComponents?.string ?? "" }
}

// MARK: - Action

enum EditLinkAction: Equatable {
    case changeName(String)
    case changeUrl(String)

    case changeQueryItemName(key: String, index: Int)
    case changeQueryItemValue(value: String, index: Int)
    case expandQueryItemValue(index: Int)
    case deleteQueryItem(index: Int)
    case addQueryItem

    case done
    case delete
    case copy
    case follow
}

// MARK: - Enviroment

protocol EditLinkEnv: AnyObject {

    func validateState(_ state: EditLinkState) -> Effect<Set<EditLinkState.ValidateableField>, Never>
    func done(state: EditLinkState) -> Effect<Void, AppError>
    func followLink(state: EditLinkState) -> Effect<Void, AppError>
    func expandQueryItemValue(value: String) -> Effect<String, Never>
}
