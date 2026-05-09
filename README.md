# TypeEraserGenerator

An extensive set of macros for creating type erasers for a protocol.

```swift
@TypeErased(options: [.selfGenerateCompositions])
protocol MyProtocol: Identifiable {
    @Erase
    @Associate<any Hashable>("ID")
    associatedtype Associate: P1, P2
    
    @Erase
    associatedtype E: Error
    
    func doThis(with: Associate) throws(E) -> Identifiable
    
    @Implementation(.error)
    static func doThat()
}
```

## How to use

### Type Eraser

This macro will generate 2 types meant for direct usage with the names of
`Any{Protocol}`, `Erased{Protocol}`.

`Any{Protocol}` is the eraser and inherits from `Erased{Protocol}`. It also
implements the `TypeEraser` protocol. It has `base` for the wrapped existential
and `init(_:)` and `init(erasing:)` for the creation of the eraser.

`Erased{Protocol}` is the erased version of the original protocol. It adds a
default as the eraser to the associated types and a default erased
implementations for the requirements.

#### Associated Types

Normally, associated types cannot be directly used by the eraser. To counteract
this, you need to also erase your associated types. Mark the associate to be
erased with `Erase` macro. It can automatically inherit the name or you can
directly specify the eraser yourself. The specified eraser must conform to
`TypeEraser`.

#### Protocol Inheritance

Inherited protocols also needs to be erased. To disable it, pass the
`disableEraserInheritance` option to the macro. Inherited protocols may
introduce associated types invisible to the macro. To make the associated types
visible to the macro attach the `Associate` or `AssociateEraser` macro to any
requirement. This will be made as declaration macro after this [issue](https://github.com/swiftlang/swift/issues/88791) is
resolved.

`Associate` macro takes the associate name as a string from the parameter,
because of this [issue](https://github.com/swiftlang/swift/issues/88792), and the requirements from the generics.

`AssociateEraser` macro takes the associate name as a string from the parameter
and the eraser from the generic.

#### Off Module Protocols

For the external protocols that you don't own, use `typeEraser` and copy the
declaration to the trailing closure. Since declaration macros with arbitrary
names cannot be put on the global scope, put this in an empty `enum` and export
the generated types to the global scope via an `typealias`.

#### Static Requirements

Normally, you can't type erase a protocol which contains static requirements. To
combat this, mark your static requirements with `Implementation` macro to give
them an explicit implementation. I takes a parameter with four options for the
type of implementation.

`error` will make it give an precondition failure when the requirement is 
called.

`value(X)` will try to satisfy the function with the value you provided. Setters
will result in a precondition failure.

`type(X.Type)` will try to satisfy the requirements from the type you provided. 

`external` will not satisfy the requirement and expects you to declare it.
For example:

```swift
extension Erased<#Protocol#> {
    static func someFunction() { \* implementation *\ }
}
```

#### Extra Options

`assureNoAssociates` will make the implementation simpler by removing implicit
casting.

`selfGenerateCompositions` will make the macro generate the required
compositions by itself. But the protocols still needs to be erased.

### Composition Type Eraser

This macro will generate an type erasers for a composition and generate a type
named `Any{Protocols|separator:Any}`. Provide the protocols via the generic. You
can list them or have a composition or a mix of both as the generic inputs. All
listed protocols must also be type erased. Since declaration macros with
arbitrary names cannot be put on the global scope, put this in an empty `enum`
and export the generated types to the global scope via an `typealias`.

Generated member name will be commutative, so it won't matter which order you
put the protocol names. To disable it, pass the `disableCommutativity` option to
the macro. Commutativity will automatically be disabled when the number of
protocols exceeds 6. Because it would've meant `5.040` names or more.

### Custom Casting

When an associate is used as an generic parameter, implicit casting cannot
handle it on its own. You need to implement the `Castable` protocol.

For example, here is how `Set` implements the `Castable` protocol:

```swift
// Implement a protocol which includes its generics as associated types and make
// your type conform to it.
protocol ErasedSet {
    associatedtype Element: Hashable
}

extension Set: ErasedSet, Castable {
    public func cast<T>(to type: T.Type) throws(CastError) -> T {
        func _cast<T2: ErasedSet>(_: T2.Type) -> T {
            // Implicit cast each element to `T2.Element`, create a set from the
            // values and cast the value to `T`.
            Set<T2.Element>(map { implicitCast($0) as T2.Element }) as! T
        }

        // Convert the type to the protocol.
        guard let arrayType = type as? any ErasedSet.Type else {
            throw .noRelation(Self.self, to: T.self)
        }

        // Implicitly open existential type.
        return _cast(arrayType)
    }
}
```

## License

This library is released under the Apache License 2.0. See
[LICENSE](LICENSE.txt) for details.
