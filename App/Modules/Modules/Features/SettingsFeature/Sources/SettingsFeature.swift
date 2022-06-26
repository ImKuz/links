import ComposableArchitecture
import ToolKit

// MARK: - State

struct SettingsOption: Equatable {
    let title: String
    let tag: String
}

struct SettingsState: Equatable {

    typealias Option = SettingsOption

    let tabOptions: [Option]
    let linkTapBehaviours: [Option]

    let appVersion: String

    @BindableState var selectedTabOption: Int
    @BindableState var selectedLinkTapBehaviourOption: Int
    @BindableState var showsConfirmAlert = false
}

// MARK: - Action

enum SettingsAction: Equatable, BindableAction {
    case binding(BindingAction<SettingsState>)
    case discardDefaults
    case restoreDefaultSettings
    case eraseAll
    case eraseAllConfirm
}

// MARK: - Enviroment

protocol SettingsEnv {
    var tabTag: String { get set }
    var linkTapBehaviour: String { get set }

    func discardDefaults()
    func restoreDefaultSettings()
    func eraseAll() -> Effect<Void, AppError>
}

// MARK: - Reducer

let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnv> { state, action, env in
    switch action {
    case .binding:
        return .none
    case .discardDefaults:
        env.discardDefaults()
        return .none
    case .restoreDefaultSettings:
        env.restoreDefaultSettings()

        state.selectedTabOption = state.tabOptions
            .firstIndex { $0.tag == env.tabTag } ?? 0

        state.selectedLinkTapBehaviourOption = state.linkTapBehaviours
            .firstIndex { $0.tag == env.linkTapBehaviour } ?? 0

        return .none
    case .eraseAll:
        state.showsConfirmAlert = true
        return .none
    case .eraseAllConfirm:
        return env
            .eraseAll()
            .fireAndForget()
    }
}.binding()
