import SwiftSyntax
import SwiftSyntaxMacros

struct DefaultExternalMacro: PeerMacro {
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

        guard defaultMacroCount(declaration) <= 1 else {
            throw ExpansionError.onlyOneSpecifierAllowed
        }

        return []
    }
}
