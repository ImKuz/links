import Models

public struct LinkItemActionData: Equatable {

    public typealias Label = (title: String, iconName: String?)

    public let itemId: LinkItem.ID
    public let label: Label?
    public let isDestructive: Bool

    public init(
        itemId: LinkItem.ID,
        label: LinkItemActionData.Label? = nil,
        isDestructive: Bool = false
    ) {
        self.itemId = itemId
        self.label = label
        self.isDestructive = isDestructive
    }

    public static func == (lhs: LinkItemActionData, rhs: LinkItemActionData) -> Bool {
        lhs.isDestructive == rhs.isDestructive &&
        lhs.label?.title == rhs.label?.title &&
        lhs.label?.iconName == rhs.label?.iconName &&
        lhs.itemId == rhs.itemId
    }
}
