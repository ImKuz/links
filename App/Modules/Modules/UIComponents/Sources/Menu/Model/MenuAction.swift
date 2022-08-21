public struct MenuAction {

    public let id: String
    public let name: String
    public let iconName: String?

    public init(
        id: String,
        name: String,
        iconName: String?
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
    }
}
