import Foundation

/// Used for implicit opening, erasing.
///
/// > Warning: Do not use directly unless you're implementing `Castable`.
func implicitCast<T1, T2>(
    _ input: T1,
    file: StaticString = #file,
    line: UInt = #line
) -> T2 {
    if T1.self == T2.self {
        return input as! T2
    }

    func initialiseTypeEraser<T: TypeEraser>(_: T.Type) -> T2? {
        guard let input = input as? T._Base_ else { return nil }
        return T(erasing: input) as? T2
    }

    if let type = T2.self as? any TypeEraser.Type,
       let value = initialiseTypeEraser(type) {
        return value
    }

    if let input = input as? any TypeEraser,
       let value = input.base as? T2 {
        return value
    }

    if let output = input as? T2 {
        return output
    }

    if let castable = input as? any Castable {
        do {
            return try castable.cast(to: T2.self)
        } catch {
            preconditionFailure(
                error.localizedDescription,
                file: file,
                line: line
            )
        }
    }

    // Point of no return

    if let input = input as? any TypeEraser {
        let name = "\(type(of: input.base))"

        preconditionFailure(
            "Could not cast value of type '\(T1.self)' with base type of '\(name)' to '\(T2.self)'.",
            file: file,
            line: line
        )
    }

    preconditionFailure(
        "Could not cast value of type '\(T1.self)' to '\(T2.self)'.",
        file: file,
        line: line
    )
}

/// A type conversion error.
public enum CastError: LocalizedError {
    /// Types have no relation.
    case noRelation(_ root: Any.Type, to: Any.Type)
    /// Unsupported conversion.
    case unsupported(_ root: Any.Type, to: Any.Type)
    /// A custom message.
    case custom(message: String)

    public var errorDescription: String? {
        switch self {
        case let .noRelation(root, cast):
            "'\(root)' has no relation with '\(cast)'"
        case let .unsupported(root, cast):
            "'\(root)' cannot be casted to '\(cast)'"
        case let .custom(message):
            message
        }
    }
}

/// A type which is convertible to an another type.
///
/// Almost all types coming here will have the same type but with a different generic clause.
///
/// For example:
/// ```swift
/// MyType<Int, String> -> MyType<Int, AnyHashable>
/// MyType<Int, AnyHashable> -> MyType<Int, String>
/// ```
public protocol Castable {
    func cast<T>(to type: T.Type) throws(CastError) -> T
}

protocol ErasedArray {
    associatedtype Element
}

extension Array: ErasedArray, Castable {
    public func cast<T>(to type: T.Type) throws(CastError) -> T {
        func _cast<T2: ErasedArray>(_: T2.Type) -> T {
            map { implicitCast($0) as T2.Element } as! T
        }

        guard let arrayType = type as? any ErasedArray.Type else {
            throw .noRelation(Self.self, to: T.self)
        }

        return _cast(arrayType)
    }
}

protocol ErasedDictionary {
    associatedtype Key: Hashable
    associatedtype Value
}

extension Dictionary: ErasedDictionary, Castable {
    public func cast<T>(to type: T.Type) throws(CastError) -> T {
        func _cast<T2: ErasedDictionary>(_: T2.Type) -> T {
            [T2.Key: T2.Value](uniqueKeysWithValues: map { (
                implicitCast($0.key) as T2.Key,
                implicitCast($0.value) as T2.Value
            ) }) as! T
        }

        guard let arrayType = type as? any ErasedDictionary.Type else {
            throw .noRelation(Self.self, to: T.self)
        }

        return _cast(arrayType)
    }
}

protocol ErasedSet {
    associatedtype Element: Hashable
}

extension Set: ErasedSet, Castable {
    public func cast<T>(to type: T.Type) throws(CastError) -> T {
        func _cast<T2: ErasedSet>(_: T2.Type) -> T {
            Set<T2.Element>(map { implicitCast($0) as T2.Element }) as! T
        }

        guard let arrayType = type as? any ErasedSet.Type else {
            throw .noRelation(Self.self, to: T.self)
        }

        return _cast(arrayType)
    }
}
