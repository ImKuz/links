import Foundation

public struct CatalogDataSourcePermissions: OptionSet {

    public let rawValue: UInt8

    public static let read = Self(rawValue: 1 << 0)
    public static let write = Self(rawValue: 1 << 1)
    public static let delete = Self(rawValue: 1 << 2)
    public static let move = Self(rawValue: 1 << 3)

    public static let all: Self = [
        .read,
        .write,
        .delete,
        .move
    ]

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}
