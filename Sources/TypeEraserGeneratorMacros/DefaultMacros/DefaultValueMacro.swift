import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct DefaultValueMacro: PeerMacro {
    static func expansion(
        of _: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let parent = context.lexicalContext.first

        guard let `protocol` = parent?.as(ProtocolDeclSyntax.self) else {
            throw ExpansionError.memberOfProtocolOnly
        }

        guard isProtocolMarkedTypeErased(`protocol`) else {
            throw ExpansionError.protocolNotMarked
        }

        guard isStatic(declaration) else {
            throw ExpansionError.onlyApplicableToStatics
        }

        if let assoc = AssociatedTypeDeclSyntax(declaration) {
            throw ExpansionError
                .assocMustHaveAErasureSpecifier(assoc: assoc.name.text)
        }

        guard defaultMacroCount(declaration) <= 1 else {
            throw ExpansionError.onlyOneSpecifierAllowed
        }

        guard try !hasSetter(declaration) else {
            throw ExpansionError.setterNotAllowed
        }

        return []
    }
}

func hasSetter(
    _ syntax: some DeclSyntaxProtocol
) throws -> Bool {
    if syntax.is(InitializerDeclSyntax.self) {
        throw ExpansionError.notApplicableToInitAndAssoc
    }

    if syntax.is(FunctionDeclSyntax.self) {
        return false
    }

    if let `subscript` = SubscriptDeclSyntax(syntax) {
        return `subscript`.accessorBlock?.accessors
            .as(AccessorDeclListSyntax.self)?
            .map(\.accessorSpecifier.trimmedDescription)
            .contains("set") ?? false
    }

    if let variable = VariableDeclSyntax(syntax) {
        return variable.bindings.first?
            .accessorBlock?.accessors
            .as(AccessorDeclListSyntax.self)?
            .map(\.accessorSpecifier.trimmedDescription)
            .contains("set") ?? false
    }

    throw ExpansionError.notSupportedDecl(kind: syntax.kind)
}
