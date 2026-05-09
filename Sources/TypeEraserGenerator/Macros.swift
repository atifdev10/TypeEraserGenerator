// The Swift Programming Language
// https://docs.swift.org/swift-book

@_exported import MultiModule

/// Generates type erasers for the attached protocol.
///
/// - Parameters:
///   - options: Changes how the macro behaves.
@attached(peer, names: prefixed(Any), prefixed(Erased), prefixed(_ErasedStorage))
public macro TypeErased(options: TypeEraserOptions = []) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "TypeEraserMacro"
)

/// Change how the macro behaves for a specific member.
///
/// Options are listed at ``TypeEraserOptions``
@attached(peer, names: overloaded)
public macro Options(_: TypeEraserOptions) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "OptionsMacro"
)

/// Specifies the type eraser to be used for the `associatedtype`.
///
/// > Tip:  Not specifying the eraser type will make automatically resolve it.
@attached(peer, names: overloaded)
public macro Erase<T: TypeEraser>() = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "EraseMacro"
)

/// Specifies the type eraser to be used for the `associatedtype`.
///
/// > Tip:  Not specifying the eraser type will make automatically resolve it.
@attached(peer, names: overloaded)
public macro Erase() = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "EraseMacro"
)

/// Adds an implementation to a static member.
///
/// Static implementations are listed at ``StaticImplementation``
@attached(peer, names: overloaded)
public macro Implementation(_: StaticImplementation) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "ImplementationMacro"
)

/// Internal use only.
@attached(extension, names: arbitrary, conformances: Equatable)
public macro __TEExtend(
    _: String,
    options: TypeEraserOptions,
    scope: ScopeLevel
) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "TEExtendMacro"
)

/// Generates a composition eraser for a composition type.
///
/// ## Overview
/// > Important: All listed protocols must be erased.
@freestanding(declaration, names: arbitrary)
public macro compositionTypeEraser<each T>(options: CompositionOptions = []) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "CompositionMacro"
)

/// Generates type erasers for an externally defined protocol.
///
/// - Parameters:
///   - options: Changes how the macro behaves.
///   - scope: Defines the access level of the eraser.
///
/// Copy paste the implementation of the protocol you want to erase.
@freestanding(declaration, names: arbitrary)
public macro typeErased(
    options: TypeEraserOptions = [],
    scope: ScopeLevel = .internal,
    _: () -> Void
) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "ExternalTypeEraserMacro"
)

/// Specifies an associate and it's constraints which would normally hidden from the macro.
@attached(peer)
public macro Associate<each Constraint>(_: StaticString, from: Any.Type = Any.self) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "AssociatedMacro"
)

/// Specifies an associate that would normally hidden from the macro.
@attached(peer)
public macro Associate(_: StaticString, from: Any.Type = Any.self) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "AssociatedMacro"
)

/// Specifies an associate with it's eraser that would normally hidden from the macro.
@attached(peer)
public macro AssociateEraser<Eraser: TypeEraser>(_: StaticString, from: Any.Type = Any.self) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "AssociatedMacro"
)

public enum StaticImplementation {
    /// Specifies the value to satisfy static requirement.
    case value(Any)
    /// Specifies which type's implementation will be used to satisfy the static requirement.
    case type(Any.Type)
    /// Specifies that the external implementation is declared via an extension of the eraser.
    case external
    /// Specifies that using this static requirement on the type eraser will result in a crash.
    case error
}
