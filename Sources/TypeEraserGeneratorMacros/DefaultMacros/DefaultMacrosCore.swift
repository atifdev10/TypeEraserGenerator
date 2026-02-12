import SwiftSyntax

let defaultMacroNames = ["DefaultValue", "DefaultType", "DefaultExternal", "DefaultNone"]

func defaultMacroCount(_ syntax: some DeclSyntaxProtocol) -> Int {
    guard
        let syntax = syntax.asProtocol((any WithAttributesSyntax).self)
    else { return 0 }

    return syntax.attributes
        .map { attribute -> String? in
            return attribute
                .as(AttributeSyntax.self)?
                .attributeName
                .as(IdentifierTypeSyntax.self)?
                .name.text
        }
        .count { defaultMacroNames.contains($0 ?? "") }
}

func isProtocolMarkedTypeErased(_ syntax: ProtocolDeclSyntax) -> Bool {
    syntax.attributes
        .map { attribute -> String? in
            return attribute
                .as(AttributeSyntax.self)?
                .attributeName
                .as(IdentifierTypeSyntax.self)?
                .name.text
        }
        .contains("TypeErased")
}

func isStatic(_ syntax: some DeclSyntaxProtocol) -> Bool {
    if syntax.is(InitializerDeclSyntax.self) ||
        syntax.is(AssociatedTypeDeclSyntax.self) {
        return true
    }

    guard let syntax = syntax.asProtocol((any WithModifiersSyntax).self) else {
        return false
    }

    return syntax.isStatic
}
