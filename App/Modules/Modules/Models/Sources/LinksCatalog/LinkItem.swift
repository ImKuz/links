import Combine
import Foundation
import ToolKit

public struct LinkItem:
    Equatable,
    Identifiable,
    Codable
{
    public let id: String
    public let name: String
    public let urlString: String
    public let isFavorite: Bool

    public init(
        id: String = UUID().uuidString,
        name: String,
        urlString: String,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.urlString = urlString
        self.isFavorite = isFavorite
    }
}
