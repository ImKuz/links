enum TabType: String {
    case favorites
    case local
    case remote
    case settings
}

struct Tab: Equatable {
    let type: TabType
    let name: String
    let iconName: String
}
