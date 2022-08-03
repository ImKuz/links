import Models
import Foundation.NSUUID

public extension LinkItem {

    func convertToEntity(withIndex index: Int) -> LinkItemEntity {
        LinkItemEntity(
            storeId: UUID().uuidString,
            itemId: id,
            name: name,
            urlString: urlString,
            index: Int16(index),
            isFavorite: isFavorite
        )
    }
}

public extension LinkItemEntity {

    func convertToModel() -> LinkItem {
        LinkItem(
            id: itemId,
            name: name,
            urlString: urlString,
            isFavorite: isFavorite
        )
    }
}
