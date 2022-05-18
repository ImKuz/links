import Foundation

extension CatalogItem: NSItemProviderWriting {

    static let typeIdentifier = "tech.polysander.CopyPasta.catalog-item"

    public static var writableTypeIdentifiersForItemProvider: [String] {
        [typeIdentifier]
    }

    public func loadData(
        withTypeIdentifier typeIdentifier: String,
        forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void
    ) -> Progress? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            completionHandler(try encoder.encode(self), nil)
        } catch {
            completionHandler(nil, error)
        }

        return nil
    }
}

extension CatalogItem: NSItemProviderReading {

    public static var readableTypeIdentifiersForItemProvider: [String] {
        [typeIdentifier]
    }

    public static func object(
        withItemProviderData data: Data,
        typeIdentifier: String
    ) throws -> CatalogItem {
        let decoder = JSONDecoder()
        return try decoder.decode(CatalogItem.self, from: data)
    }
}

