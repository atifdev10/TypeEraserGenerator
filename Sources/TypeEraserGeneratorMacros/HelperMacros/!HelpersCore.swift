import SwiftSyntax
import SwiftSyntaxMacros

let helperMacroNames = ["Default", "Erase", "Options"]

func attributeCount(
    _ syntax: some DeclSyntaxProtocol,
    name: String
) -> Int {
    guard let syntax = syntax.asProtocol((any WithAttributesSyntax).self) else {
        return 0
    }

    return syntax.attributeNames.count { $0 == name }
}

func isStatic(_ syntax: some DeclSyntaxProtocol) -> Bool {
    guard let syntax = syntax.asProtocol((any WithModifiersSyntax).self) else {
        return false
    }

    return syntax.isStatic
}
