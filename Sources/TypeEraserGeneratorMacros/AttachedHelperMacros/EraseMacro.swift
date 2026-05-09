import SwiftSyntax
import SwiftSyntaxMacros

struct EraseMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let parent = context.lexicalContext.first

        guard let `protocol` = ProtocolDeclSyntax(parent) else {
            throw NotProtocolRequirementError()
        }

        guard isAttachedHelperPlacementValid(for: `protocol`, context: context) else {
            throw NotTypeErasedProtocolError()
        }

        guard declaration.is(AssociatedTypeDeclSyntax.self) else {
            throw MacroError("Only associated types can have an eraser")
        }

        guard attributeCount(declaration, name: node.name) < 2 else {
            throw MacroError("Associated types must have a single eraser")
        }

        return []
    }
}
