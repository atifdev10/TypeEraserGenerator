import SwiftSyntax
import SwiftSyntaxMacros

struct DefaultMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let parent = context.lexicalContext.first

        guard let `protocol` = ProtocolDeclSyntax(parent) else {
            throw ExpansionError.memberOfProtocolOnly
        }

        guard `protocol`.attributeNames.contains("TypeErased") else {
            throw ExpansionError.protocolNotMarked
        }

        guard isStatic(declaration) else {
            throw ExpansionError.onlyApplicableToStatics
        }

        guard attributeCount(declaration, name: node.name) < 2 else {
            throw ExpansionError.onlyOneDefaultAllowed
        }

        return []
    }
}


