import SwiftSyntax
import SwiftSyntaxMacros

let attachedHelperMacroNames = ["Implementation", "Erase", "Options", "Associate", "AssociateEraser"]

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

func isAttachedHelperPlacementValid(
    for protocol: ProtocolDeclSyntax,
    context: some MacroExpansionContext
) -> Bool {
    if `protocol`.attributeNames.contains("TypeErased") {
        return true
    }

    guard context.lexicalContext.count > 2 else {
        return false
    }

    let macro = context.lexicalContext[2]

    if let macro = MacroExpansionDeclSyntax(macro) {
        return macro.macroName.trimmedDescription == "generateEraser"
    }

    if let macro = MacroExpansionExprSyntax(macro) {
        return macro.macroName.trimmedDescription == "generateEraser"
    }

    return false
}
