import Models

public struct LinkItemActionData {

    public typealias Label = (title: String, iconName: String?)

    public let itemId: LinkItem.ID
    public let label: Label?

    public init(itemId: LinkItem.ID, label: LinkItemActionData.Label? = nil) {
        self.itemId = itemId
        self.label = label
    }
}
