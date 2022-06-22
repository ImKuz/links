import Foundation

public extension NSPredicate {

    enum MatchingOperator: String {
        case beginsWith = "BEGINSWITH"
        case contains = "CONTAINS"
        case endsWith = "ENDSWITH"
        case like = "LIKE"
        case matches = "MATCHES"
    }

    typealias CompoundType = NSCompoundPredicate.LogicalType

    static func compound(_ predicates: [NSPredicate], by type: CompoundType = .and) -> NSPredicate {
        NSCompoundPredicate(type: type, subpredicates: predicates)
    }

    static func compound(_ predicates: NSPredicate..., by type: CompoundType = .and) -> NSPredicate {
        NSCompoundPredicate(type: type, subpredicates: predicates)
    }

    static func not(_ predicate: NSPredicate) -> NSPredicate {
        NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
    }
}
