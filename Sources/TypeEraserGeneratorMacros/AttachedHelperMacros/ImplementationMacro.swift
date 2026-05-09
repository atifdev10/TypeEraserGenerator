import SwiftSyntax
import SwiftSyntaxMacros

struct ImplementationMacro: PeerMacro {
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

        guard isStatic(declaration) else {
            throw MacroError("Non-static requirements cannot have an explicit implementation")
        }

        guard attributeCount(declaration, name: node.name) < 2 else {
            throw MacroError("Static requirements must have a single explicit implementation")
        }

        return []
    }
}
