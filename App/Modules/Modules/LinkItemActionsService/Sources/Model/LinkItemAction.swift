public enum LinkItemAction: LinkItemActionRepresentable {

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

    func withData(_ data: Data) -> WithData {
        WithData(action: self, data: data)
    }
}

public struct LinkItemActionWithData: LinkItemActionRepresentable {

    public let action: LinkItemAction
    public let data: LinkItemActionData

    public init(action: LinkItemAction, data: LinkItemActionData) {
        self.action = action
        self.data = data
    }
}

public protocol LinkItemActionRepresentable {
    var action: LinkItemAction { get }
}
