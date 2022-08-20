import IdentifiedCollections
import Models

enum CatalogRowDataMapper {

    static func map(
        item: LinkItem,
        actions: [RowMenuAction]
    ) -> CatalogRowState {
        return .init(
            id: item.id,
            title: item.name,
            contentPreview: String(item.urlString.prefix(25))
        )
    }
}
