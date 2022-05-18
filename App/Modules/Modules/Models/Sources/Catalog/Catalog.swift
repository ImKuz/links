import Foundation

public enum CatalogItemContent: Equatable, Codable {
    case text(String)
    case link(URL)
}
