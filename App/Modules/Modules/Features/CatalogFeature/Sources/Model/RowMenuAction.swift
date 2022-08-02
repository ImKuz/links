
struct RowMenuAction: Equatable {

    let iconName: String
    let title: String
    let action: CatalogRowAction
    let isDestructive: Bool

    init(
        iconName: String,
        title: String,
        action: CatalogRowAction,
        isDestructive: Bool = false
    ) {
        self.iconName = iconName
        self.title = title
        self.action = action
        self.isDestructive = isDestructive
    }
}
