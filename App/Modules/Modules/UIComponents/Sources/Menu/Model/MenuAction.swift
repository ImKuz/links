public struct MenuAction {

    public let id: String
    public let name: String
    public let iconName: String?
    public let isDestructive: Bool

    public init(
        id: String,
        name: String,
        iconName: String?,
        isDestructive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.isDestructive = isDestructive
    }
}
