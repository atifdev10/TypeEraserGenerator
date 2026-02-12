import Foundation
import Helpers

/// A type that erases an existential type.
public protocol TypeEraser {
    associatedtype T
    init(erasing: T)
    var base: T { get }
}

extension AnyHashable: TypeEraser {
    public init(erasing: any Hashable) {
        self.init(erasing)
    }

    /// An overload of `base` any hashable that returns existential `Hashable`.
    @_disfavoredOverload
    public var base: any Hashable {
        self[keyPath: anyHashableBaseKeypath] as! any Hashable
    }
}

/// Type eraser for `Identifiable` protocol.
public struct AnyIdentifiable: Identifiable, TypeEraser {
    public typealias ID = AnyHashable
    public var base: any Identifiable

    public init(_ erasing: some Identifiable) {
        base = erasing
    }

    public init(erasing: any Identifiable) {
        base = erasing
    }

    public var id: Self.ID {
        func id_genericOpen<T: Identifiable>(_: T) -> Self.ID {
            var base: T {
                self.base as! T
            }
            return base.id
        }; return _openExistential(base, do: id_genericOpen)
    }
}

/// Type eraser for `Equatable` protocol.
public struct AnyEquatable: Equatable, TypeEraser {
    public var base: any Equatable
    public init(_ erasing: some Equatable) {
        base = erasing
    }

    public init(erasing: any Equatable) {
        base = erasing
    }

    public static func == (left: Self, right: Self) -> Bool {
        _isEqual(lhs: left.base, rhs: right.base)
    }

    private static func _isEqual<T: Equatable, U: Equatable>(lhs: T, rhs: U) -> Bool {
        if let rhsAsT = rhs as? T {
            return lhs == rhsAsT
        }
        if let lhsAsU = lhs as? U {
            return lhsAsU == rhs
        }
        return false
    }
}

/// Type eraser for `Error` protocol.
///
///  > Important:
///     Type eraser will infer this as `any Error`.
public struct AnyError: Error, TypeEraser {
    public init(erasing: any Error) {
        base = erasing
    }

    public var base: any Error
}
