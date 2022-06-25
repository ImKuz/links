import ComposableArchitecture

// MARK: - State

struct SettingsState: Equatable {

    let tabOptions: [String]
    let linkTapBehaviour: [String]

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
    func setTabTag(_ value: String)
    func setLinkTapBehaviour(_ value: String)
    func discardDefaults()
    func restoreDefaultSettings()
    func eraseAll()
}

// MARK: - Reducer

let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnv> { state, action, env in
    switch action {
    case .binding:
        return .none
    case .discardDefaults:
        return .none
    case .restoreDefaultSettings:
        return .none
    case .eraseAll:
        return .none
    case .eraseAllConfirm:
        return .none
    }
}.binding()
