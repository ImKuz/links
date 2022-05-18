enum TabType: Int {
    case favorites
    case local
    case remote
}

struct Tab: Equatable, Identifiable {
    var id: Int { type.rawValue }
    let type: TabType
    let name: String
    let iconName: String
}
