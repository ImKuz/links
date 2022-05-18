import ToolKit
import IdentifiedCollections
import Foundation

public struct Catalog: Equatable {
    public let items: CatalogItem
}

public enum CatalogItemContent: Equatable, Codable {
    case text(String)
    case link(URL)
}
