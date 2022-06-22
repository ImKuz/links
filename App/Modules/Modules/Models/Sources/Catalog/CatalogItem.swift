import Foundation

public struct CatalogItem:
    Equatable,
    Identifiable,
    Codable
{
    public let id: String
    public let _name: String?
    public let content: CatalogItemContent

    public let isFavorite: Bool

    public var name: String {
        _name ?? nameFromContent()
    }

    public init(
        id: String,
        name: String?,
        content: CatalogItemContent,
        isFavorite: Bool
    ) {
        self.id = id
        self._name = name
        self.content = content
        self.isFavorite = isFavorite
    }

    public static func == (lhs: CatalogItem, rhs: CatalogItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.content == rhs.content &&
        lhs.isFavorite == rhs.isFavorite
    }
}

public extension CatalogItem {

    init(name: String?, link: URL) {
        self.init(
            id: UUID().uuidString,
            name: name,
            content: .link(link),
            isFavorite: false
        )
    }

    init(name: String?, text: String) {
        self.init(
            id: UUID().uuidString,
            name: name,
            content: .text(text),
            isFavorite: false
        )
    }
}

public extension CatalogItem {

    func modified(name: String? = nil, content: CatalogItemContent? = nil) -> Self {
        return .init(
            id: id,
            name: name ?? self.name,
            content: content ?? self.content,
            isFavorite: self.isFavorite
        )
    }

    private func nameFromContent() -> String {
        switch content {
        case let .link(url):
            return url.description
        case let .text(text):
            return text
        }
    }
}
