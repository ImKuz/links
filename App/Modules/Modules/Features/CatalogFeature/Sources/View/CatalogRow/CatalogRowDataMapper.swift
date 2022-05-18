import IdentifiedCollections
import Models

enum CatalogRowDataMapper {

    static func map(_ item: CatalogItem) -> CatalogRowState {
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
            title: item.name,
            content: content,
            icon: icon
        )
    }

    static func map(_ items: IdentifiedArrayOf<CatalogItem>) -> [CatalogRowState] {
        items.map(Self.map)
    }
}
