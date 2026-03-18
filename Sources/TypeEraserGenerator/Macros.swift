// The Swift Programming Language
// https://docs.swift.org/swift-book

@_exported import MultiModule

/// Generates type erasers for the attached protocol.
///
/// - Parameters:
///   - options: Changes how the macro behaves.
///
/// ## Overview
@attached(extension, names: arbitrary)
@attached(peer, names: prefixed(Any))
@attached(member, names: arbitrary)
public macro TypeErased(options: TypeEraserOptions = []) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "TypeEraserMacro"
)

/// Change how the macro behaves for a specific member.
///
/// ## Overview
/// Options are listed at ``TypeEraserOptions``
@attached(peer, names: overloaded)
public macro Options(_ options: TypeEraserOptions) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "OptionsMacro"
)

/// Specifies the type eraser to be used for the `associatedtype`.
///
/// ## Overview
///
/// > Tip:  Not specifying the eraser type will make automatically resolve it.
@attached(peer, names: overloaded)
public macro Erase<T: TypeEraser>() = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "EraseMacro"
)

/// Specifies the type eraser to be used for the `associatedtype`.
///
/// ## Overview
///
/// > Tip:  Not specifying the eraser type will make automatically resolve it.
@attached(peer, names: overloaded)
public macro Erase() = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "EraseMacro"
)

/// Change how the macro behaves for a specific member.
///
/// ## Overview
/// Default behaviors are listed at ``DefaultBehavior``
@attached(peer, names: overloaded)
public macro Default(_ default: DefaultBehavior) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "DefaultMacro"
)

public enum DefaultBehavior {
    /// Specifies the value to satisfy static requirement.
    case value(Any)
    /// Specifies which type's implementation will be used to satisfy the static requirement.
    case type(Any.Type)
    /// Specifies that the external implementation is declared via an extension of the eraser.
    case external
    /// Specifies that using this static requirement on the type eraser will result in a crash.
    case error
}
