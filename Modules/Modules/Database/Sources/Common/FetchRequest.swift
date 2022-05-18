import Foundation

public struct FetchRequest {

    // MARK: - Public properties

    public var sortDescriptor: NSSortDescriptor?
    public var predicate: NSPredicate?
    public var fetchOffset: Int
    public var fetchLimit: Int

    // MARK: - Lifecycle

    public init(
        sortDescriptor: NSSortDescriptor? = nil,
        predicate: NSPredicate? = nil,
        fetchOffset: Int = 0,
        fetchLimit: Int = 0
    ) {
        self.sortDescriptor = sortDescriptor
        self.predicate = predicate
        self.fetchOffset = fetchOffset
        self.fetchLimit = fetchLimit
    }

    // MARK: - Public methods

    @discardableResult
    public mutating func apply(_ predicate: NSPredicate) -> Self {
        if let appliedPredicate = self.predicate {
            self.predicate = .compound(appliedPredicate, predicate)
        } else {
            self.predicate = predicate
        }

        return self
    }

    @discardableResult
    public mutating func sort(with sortDescriptor: NSSortDescriptor) -> Self {
        self.sortDescriptor = sortDescriptor
        return self
    }

    @discardableResult
    public mutating func sort(with key: String?, isAscending: Bool) -> Self {
        self.sortDescriptor = NSSortDescriptor(key: key, ascending: isAscending)
        return self
    }
}
