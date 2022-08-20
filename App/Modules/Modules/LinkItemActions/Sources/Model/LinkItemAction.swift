import Models

public enum LinkItemAction: LinkItemActionRepresentable, Equatable {

    public typealias Data = LinkItemActionData
    public typealias WithData = LinkItemActionWithData

    case copy
    case open
    case edit
    case delete
    case setIsFavorite(Bool)

    public var action: LinkItemAction {
        self
    }

    public func withData(_ data: Data) -> WithData {
        WithData(action: self, data: data)
    }
}

public struct LinkItemActionWithData: LinkItemActionRepresentable, Equatable {

    public let action: LinkItemAction
    public let data: LinkItemActionData

    public init(action: LinkItemAction, data: LinkItemActionData) {
        self.action = action
        self.data = data
    }

    public init(action: LinkItemAction, itemId: LinkItem.ID) {
        self.action = action
        self.data = .init(itemId: itemId)
    }
}

public protocol LinkItemActionRepresentable {
    var action: LinkItemAction { get }
}
