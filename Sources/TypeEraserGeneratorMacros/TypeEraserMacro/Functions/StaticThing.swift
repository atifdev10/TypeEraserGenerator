import SwiftSyntax

func getIfStaticAsNonStatic(_ syntax: DeclSyntax) -> DeclSyntax? {
    if syntax.is(InitializerDeclSyntax.self) ||
        syntax.is(TypeAliasDeclSyntax.self) ||
        syntax.is(AssociatedTypeDeclSyntax.self) {
        return nil
    }

    guard
        var syntax = syntax.asProtocol((any WithModifiersSyntax).self),
        syntax.isStatic
    else { return nil }

    syntax.modifiers.remove { syntax in
        syntax.name.trimmedDescription == "static"
    }

    return DeclSyntax(syntax)
}
