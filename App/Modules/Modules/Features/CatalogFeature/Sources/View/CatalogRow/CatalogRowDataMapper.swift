import IdentifiedCollections
import Models

enum CatalogRowDataMapper {

    static func map(
        item: CatalogItem,
        actions: [CatalogState.RowMenuAction]
    ) -> CatalogRowState {
        let content: String
        let icon: CatalogRowState.Icon

        switch item.content {
        case let .link(url):
            content = url.absoluteString
            icon = .link
        case let .text(string):
            content = string
            icon = .text
        }

        return .init(
            id: item.id,
            title: item.name,
            content: content,
            icon: icon,
            actions: actions
        )
    }
}
