import Combine
import Foundation
import ToolKit

public struct LinkItem:
    Equatable,
    Identifiable,
    Codable
{
    public enum Spec {
        public static let defaultName = "Untitled link"
    }

    public let id: String
    public let name: String
    public let urlString: String
    public let isFavorite: Bool

    public var isEmpty: Bool {
        name == Spec.defaultName && urlString.isEmpty
    }

    public init(
        id: String = UUID().uuidString,
        name: String = Spec.defaultName,
        urlString: String = "",
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.urlString = urlString
        self.isFavorite = isFavorite
    }
}
