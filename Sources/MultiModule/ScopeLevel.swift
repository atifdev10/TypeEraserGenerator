import Foundation

public enum ScopeLevel {
    /// The `open` visibility level.
    case open
    /// The `public` visibility level.
    case `public`
    /// The `package` visibility level.
    case package
    /// The `internal` visibility level.
    case `internal`
    /// The `fileprivate` visibility level.
    case `fileprivate`
    /// The `private` visibility level.
    case `private`

    public init?(string: String) {
        switch string {
        case "open", "`open`":
            self = .open

        case "public", "`public`":
            self = .public

        case "package", "`package`":
            self = .package

        case "internal", "`internal`":
            self = .internal

        case "fileprivate", "`fileprivate`":
            self = .fileprivate

        case "private", "`private`":
            self = .private

        default:
            return nil
        }
    }

    public var scope: String {
        switch self {
        case .open:
            "open"

        case .public:
            "public"

        case .package:
            "package"

        case .internal:
            "internal"

        case .fileprivate:
            "fileprivate"

        case .private:
            "private"
        }
    }

    public var accessSyntax: String {
        switch self {
        case .open:
            ".`open`"

        case .public:
            ".`public`"

        case .package:
            ".`package`"

        case .internal:
            ".`internal`"

        case .fileprivate:
            ".`fileprivate`"

        case .private:
            ".`private`"
        }
    }
}
