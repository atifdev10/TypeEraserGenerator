import Foundation
import Helpers
import SwiftUI

/// A type that erases an existential type.
public protocol TypeEraser {
    associatedtype _Base_
    /// Create an instance that type-erases `Identifiable`.
    init(erasing: _Base_)
    /// The value wrapped by this instance.
    var base: _Base_ { get set }
}

extension AnyHashable: TypeEraser {
    public init(erasing: any Hashable) {
        self.init(erasing)
    }

    /// An overload of `base` that returns an existential `Hashable`.
    @_disfavoredOverload
    public var base: any Hashable {
        get {
            self[keyPath: anyHashableBaseKeyPath] as! any Hashable
        }
        set {
            self = AnyHashable(newValue)
        }
    }
}

public protocol ErasedHashable: TypeEraser, ErasedEquatable, Hashable {}

extension ErasedHashable {
    private var base_Hashable: any Hashable {
        get { base as! any Hashable }
        set { base = newValue as! _Base_ }
    }

    public func hash(into hasher: inout Hasher) {
        base_Hashable.hash(into: &hasher)
    }
}

public enum EraserStorage {}

/// A type erased `Identifiable` value.
public struct AnyIdentifiable: TypeEraser, ErasedIdentifiable {
    /// The value wrapped by this instance.
    public var base: any Identifiable
    /// Create an instance that type-erases `Identifiable`.
    public init(_ erasing: some Identifiable) {
        base = erasing
    }

    /// Create an instance that type-erases `Identifiable`.
    public init(erasing: any Identifiable) {
        base = erasing
    }
}

public protocol ErasedIdentifiable: TypeEraser, Identifiable {
    associatedtype ID: Hashable = AnyHashable
}

public extension ErasedIdentifiable {
    private var base_Identifiable: any Identifiable {
        get {
            base as! any Identifiable
        }
        set {
            base = newValue as! _Base_
        }
    }

    var id: ID {
        func id_genericOpen<_OpenBase_: Identifiable>(_: _OpenBase_) -> ID {
            var localBase: _OpenBase_ {
                base_Identifiable as! _OpenBase_
            }
            return implicitCast(localBase.id)
        }
        return implicitCast(_openExistential(base_Identifiable, do: id_genericOpen))
    }
}

/// A type erased `Equatable` value.
public struct AnyEquatable: TypeEraser, ErasedEquatable {
    /// The value wrapped by this instance.
    public var base: any Equatable
    /// Create an instance that type-erases `Equatable`.
    public init(_ erasing: some Equatable) {
        base = erasing
    }

    /// Create an instance that type-erases `Equatable`.
    public init(erasing: any Equatable) {
        base = erasing
    }
}

public protocol ErasedEquatable: TypeEraser, Equatable {}

extension ErasedEquatable {
    private var base_Equatable: any Equatable {
        get {
            base as! any Equatable
        }
        set {
            base = newValue as! _Base_
        }
    }

    public static func == (left: Self, right: Self) -> Bool {
        _isEqual(lhs: left.base_Equatable, rhs: right.base_Equatable)
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

/// A type erased `Error` value.
///
///  > Important:
///     Type eraser will infer this as `any Error`.
public struct AnyError: Error, TypeEraser {
    public init(_ erasing: some Error) {
        base = erasing
    }

    public init(erasing: any Error) {
        base = erasing
    }

    public var base: any Error
}
