import Foundation
import MultiModule
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

enum TypeEraserMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let `protocol` = try getRawProtocol(from: declaration, node: node)
        let globalOptions = try getOptions(node: node)

        let scope = {
            let modifiers = `protocol`.modifiers.map(\.name.text)
                .map { $0.replacingOccurrences(of: "`", with: "") }

            for modifier in modifiers {
                guard let scope = ScopeLevel(string: modifier) else {
                    continue
                }

                return scope
            }

            return ScopeLevel.internal
        }()

        return try generationCore(
            context: context,
            options: globalOptions,
            protocol: `protocol`,
            scope: scope
        )
    }
}
