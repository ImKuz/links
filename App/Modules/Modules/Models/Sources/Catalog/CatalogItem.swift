import Foundation

public final class CatalogItem:
    NSObject,
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
}

public extension CatalogItem {

    convenience init(name: String?, link: URL) {
        self.init(
            id: UUID().uuidString,
            name: name,
            content: .link(link),
            isFavorite: false
        )
    }

    convenience init(name: String?, text: String) {
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
