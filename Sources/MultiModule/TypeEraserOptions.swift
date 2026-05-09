import Foundation

public struct TypeEraserOptions: OptionSet, Sendable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Improves performance by removing implicit casting and existential opening.
    public static let assureNoAssociates = TypeEraserOptions(rawValue: 1 << 0)

    /// Disables eraser inheritance.
    public static let disableEraserInheritance = TypeEraserOptions(rawValue: 1 << 1)

    /// Generates the required composition erasers by itself.
    public static let selfGenerateCompositions = TypeEraserOptions(rawValue: 1 << 1)

    public init?(string: String) {
        switch string {
        case "assureNoAssociates":
            self = .assureNoAssociates

        case "disableEraserInheritance":
            self = .disableEraserInheritance

        case "selfGenerateCompositions":
            self = .selfGenerateCompositions

        default:
            return nil
        }
    }

    public var _arrayDescription: String {
        var strings = [String]()

        if contains(.assureNoAssociates) {
            strings.append(".assureNoAssociates")
        }

        if contains(.disableEraserInheritance) {
            strings.append(".disableEraserInheritance")
        }

        if contains(.selfGenerateCompositions) {
            strings.append(".selfGenerateCompositions")
        }

        return "[" + strings.joined(separator: ",") + "]"
    }
}
