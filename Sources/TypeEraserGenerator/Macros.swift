// The Swift Programming Language
// https://docs.swift.org/swift-book

/// Generates type erasers for the attached protocol.
///
/// - Parameters:
///   - conformances: Used for exposing protocol inheritances that the macro can't see.
///   - options: Extra options to change how the macro behaves.
@attached(extension, names: arbitrary)
@attached(peer, names: prefixed(Any))
@attached(member, names: arbitrary)
public macro TypeErased(
    conformances: Conformance...,
    options: TypeEraserOptions = []
) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "TypeEraserMacro"
)

/// Generates type erasers for the attached protocol.
///
/// - Parameters:
///   - options: Extra options to change how the macro behaves.
@attached(extension, names: arbitrary)
@attached(peer, names: prefixed(Any))
@attached(member, names: arbitrary)
public macro TypeErased(options: TypeEraserOptions = []) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "TypeEraserMacro"
)

/// Specifies the type eraser to be used for the `associatedtype`.
@attached(peer, names: overloaded)
public macro ErasureType<T: TypeEraser>() = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "ErasureMacro"
)

/// Specifies which type's implementation will be used to satisfy the static requirement.
@attached(peer, names: overloaded)
public macro DefaultType<T>() = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "DefaultTypeMacro"
)

/// Specifies the value to satisfy static requirement.
@attached(peer, names: overloaded)
public macro DefaultValue<T>(_: T) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "DefaultValueMacro"
)

/// Specifies the external implementation to satisfy the static requirement.
///
/// Make sure the function's labels, input/return types and specifiers match. Do
/// know that associated types have been replaced with their corresponding erasers
/// that you specified.
///
/// ### Variable
/// ```swift
/// // Get
/// func name() /* async throws */ -> /* type */
/// // Set
/// func name(_ newValue: /* type */) /* async throws */
/// ```
///
/// ### Function
/// ```swift
/// func name(/* parameters */) /* async throws */ -> /* type */
/// ```
///
/// ### Subscript
/// Please make sure that functions parameters follow the subscript's label parsing.
/// ```swift
/// // Get
/// func name(/* parameters */) /* async throws */ -> /* type */
/// // Set
/// func name(_ newValue: /* type */, /* parameters */) /* async throws */
/// ```
///
/// ### Initializer
/// If the initializer is failable, make sure to return an optional.
/// ```swift
/// func name(/* parameters */) /* async throws */ -> /* type */
/// ```
@attached(peer, names: overloaded)
public macro DefaultExternal<each T, E, R>(
    _: (repeat each T) async throws(E) -> R
) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "DefaultExternalMacro"
)
/**/
/// Specifies the external implementation to satisfy the static requirement.
///
/// Make sure the function's labels, input/return types and specifiers match. Do
/// know that associated types have been replaced with their corresponding erasers
/// that you specified.
///
/// Use this version for the requirements that both have a getter and a setter.
///
/// ### Variable
/// ```swift
/// // Get
/// func name() /* async throws */ -> /* type */
/// // Set
/// func name(_ newValue: /* type */) /* async throws */
/// ```
///
/// ### Function
/// ```swift
/// func name(/* parameters */) /* async throws */ -> /* type */
/// ```
///
/// ### Subscript
/// Please make sure that functions parameters follow the subscript's label parsing.
/// ```swift
/// // Get
/// func name(/* parameters */) /* async throws */ -> /* type */
/// // Set
/// func name(_ newValue: /* type */, /* parameters */) /* async throws */
/// ```
///
/// ### Initializer
/// If the initializer is failable, make sure to return an optional.
/// ```swift
/// func name(/* parameters */) /* async throws */ -> /* type */
/// ```
@attached(peer, names: overloaded)
public macro DefaultExternal<each T, E, R, each T2, E2, R2>(
    _: (repeat each T) async throws(E) -> R,
    _: (repeat each T2) async throws(E2) -> R2
) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "DefaultExternalMacro"
)

/// Specifies the external implementation to satisfy the static requirement.
///
/// Make sure the function's labels, input/return types and specifiers match. Do
/// know that associated types have been replaced with their corresponding erasers
/// that you specified.
///
/// Use this version if the implementation you provided is defined in the extension of
/// the generated type eraser.
///
/// ### Variable
/// ```swift
/// // Get
/// func name() /* async throws */ -> /* type */
/// // Set
/// func name(_ newValue: /* type */) /* async throws */
/// ```
///
/// ### Function
/// ```swift
/// func name(/* parameters */) /* async throws */ -> /* type */
/// ```
///
/// ### Subscript
/// Please make sure that functions parameters follow the subscript's label parsing.
/// ```swift
/// // Get
/// func name(/* parameters */) /* async throws */ -> /* type */
/// // Set
/// func name(_ newValue: /* type */, /* parameters */) /* async throws */
/// ```
///
/// ### Initializer
/// If the initializer is failable, make sure to return an optional.
/// ```swift
/// func name(/* parameters */) /* async throws */ -> /* type */
/// ```
@attached(peer, names: overloaded)
public macro DefaultExternal(_: StaticString) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "DefaultExternalMacro"
)

/// Specifies the external implementation to satisfy the static requirement.
///
/// Make sure the function's labels, input/return types and specifiers match. Do
/// know that associated types have been replaced with their corresponding erasers
/// that you specified.
///
/// Use this version if the implementation you provided is defined in the extension of
/// the generated type eraser and for the requirements that both have a getter and a
/// setter.
///
/// ### Variable
/// ```swift
/// // Get
/// func name() /* async throws */ -> /* type */
/// // Set
/// func name(_ newValue: /* type */) /* async throws */
/// ```
///
/// ### Function
/// ```swift
/// func name(/* parameters */) /* async throws */ -> /* type */
/// ```
///
/// ### Subscript
/// Please make sure that functions parameters follow the subscript's label parsing.
/// ```swift
/// // Get
/// func name(/* parameters */) /* async throws */ -> /* type */
/// // Set
/// func name(_ newValue: /* type */, /* parameters */) /* async throws */
/// ```
///
/// ### Initializer
/// If the initializer is failable, make sure to return an optional.
/// ```swift
/// func name(/* parameters */) /* async throws */ -> /* type */
/// ```
@attached(peer, names: overloaded)
public macro DefaultExternal(_: StaticString, _: StaticString) = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "DefaultExternalMacro"
)

/// Specifies that using this static requirement on the type eraser will result in a fatal error.
@attached(peer, names: overloaded)
public macro DefaultNone() = #externalMacro(
    module: "TypeEraserGeneratorMacros",
    type: "DefaultNoneMacro"
)

public enum Conformance {
    case hashable
    case equatable
    case identifiable(Any.Type)
}

public struct TypeEraserOptions: OptionSet, Sendable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Makes the static requirements accessible from the value level.
    public static let exportStaticRequirements = TypeEraserOptions(rawValue: 1 << 0)
}

@TypeErased
protocol Protocol {
    @DefaultExternal(aaaaa) init?()
}

func aaaaa() -> AnyProtocol? {
    nil
}
