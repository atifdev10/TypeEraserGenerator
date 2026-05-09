import SwiftSyntax
import SwiftSyntaxMacros

struct AssociatedMacro: PeerMacro {
    static func expansion(
        of _: AttributeSyntax,
        providingPeersOf _: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let parent = context.lexicalContext.first

        guard let `protocol` = ProtocolDeclSyntax(parent) else {
            throw NotProtocolRequirementError()
        }

        guard isAttachedHelperPlacementValid(for: `protocol`, context: context) else {
            throw NotTypeErasedProtocolError()
        }

        return []
    }
}
