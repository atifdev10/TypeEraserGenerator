import Foundation

public struct TypeEraserOptions: OptionSet, Sendable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Makes the static requirements accessible from the value level.
    public static let exportStaticToObjectLevel = TypeEraserOptions(rawValue: 1 << 0)

    /// Improves performance by removing implicit casting and existential opening.
    public static let assureNoAssociates = TypeEraserOptions(rawValue: 1 << 1)

    public init?(string: String) {
        switch string {
        case "exportStaticToObjectLevel":
            self = .exportStaticToObjectLevel
        case "assureNoAssociates":
            self = .assureNoAssociates
        default:
            return nil
        }
    }
}
