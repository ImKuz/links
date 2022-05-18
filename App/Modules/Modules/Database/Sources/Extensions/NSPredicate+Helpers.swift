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

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type>,
        equalTo value: Value
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) == %@",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type?>,
        equalTo value: Value
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) == %@",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type>,
        in list: [Value]
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) IN %@",
            list.map { String($0) }
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type?>,
        in list: [Value]
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) IN %@",
            list.map { String($0) }
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type>,
        moreThan value: Value
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) > %@",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type?>,
        moreThan value: Value
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) > %@",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type>,
        moreThanOrEqual value: Value
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) >= %@",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type?>,
        moreThanOrEqual value: Value
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) >= %@",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type>,
        lessThan value: Value
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) < %@",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type?>,
        lessThan value: Value
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) < %@",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type>,
        lessThanOrEqual value: Value
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) <= %@",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type?>,
        lessThanOrEqual value: Value
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) <= %@",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type>,
        value: Value,
        operator: MatchingOperator
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) \(`operator`.rawValue)",
            String(value)
        )
    }

    static func filter<Model: NSObject, Type, Value: LosslessStringConvertible>(
        keyPath: KeyPath<Model, Type?>,
        value: Value,
        operator: MatchingOperator
    ) -> NSPredicate {
        .init(
            format: "\(NSExpression(forKeyPath: keyPath).keyPath) \(`operator`.rawValue)",
            String(value)
        )
    }
}
