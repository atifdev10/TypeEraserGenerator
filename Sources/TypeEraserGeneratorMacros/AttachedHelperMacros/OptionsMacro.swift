import SwiftSyntax
import SwiftSyntaxMacros

struct OptionsMacro: PeerMacro {
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

        guard attributeCount(declaration, name: node.name) < 2 else {
            throw MacroError("Trailing closure must be used")
        }

        return []
    }
}
