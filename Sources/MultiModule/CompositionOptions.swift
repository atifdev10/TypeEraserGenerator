import Foundation

public struct CompositionOptions: OptionSet, Sendable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Disables the ability to change the protocol name order of the composition eraser.
    public static let disableCommutativity = CompositionOptions(rawValue: 1 << 0)

    public init?(string: String) {
        switch string {
        case "disableCommutativity":
            self = .disableCommutativity

        default:
            return nil
        }
    }

    public var _arrayDescription: String {
        var strings = [String]()

        if contains(.disableCommutativity) {
            strings.append(".disableCommutativity")
        }

        return "[" + strings.joined(separator: ",") + "]"
    }
}
