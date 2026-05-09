import Foundation
import MultiModule
import SwiftSyntax
import SwiftSyntaxMacros

enum ExternalTypeEraserMacro: DeclarationMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let declaration = try {
            guard let closure = node.trailingClosure else {
                throw MacroError("Trailing closure must be used")
            }

            return closure.statements.trimmedDescription
        }()

        let `protocol` = try asProtocol(from: declaration)
        let globalOptions = try getOptions(node: node)

        let scope = {
            guard
                let labelList = LabeledExprListSyntax(node.arguments),
                let scopeArgument = labelList.first(where: {
                    $0.label?.trimmedDescription == "scope"
                }),
                let scopeExpr = MemberAccessExprSyntax(scopeArgument.expression),
                let scope = ScopeLevel(string: scopeExpr.declName.baseName.text)
            else {
                return ScopeLevel.internal
            }

            return scope
        }()

        return try generationCore(
            context: context,
            options: globalOptions,
            protocol: `protocol`,
            scope: scope
        )
    }
}
