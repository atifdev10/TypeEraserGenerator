import Foundation
import MultiModule
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum TEExtendMacro: ExtensionMacro {
    static func expansion(
        of node: AttributeSyntax,
        attachedTo _: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let list = LabeledExprListSyntax(node.arguments)!

        let globalOptions = try getOptions(node: node)

        let `protocol` = try {
            let expression = list[list.index(at: 0)].expression
            let stringLiteral = StringLiteralExprSyntax(expression)!
            let protocolString = stringLiteral.segments
                .map(\.trimmedDescription)
                .joined()

            return try ProtocolDeclSyntax("\(raw: protocolString)")
        }()

        let scope: TokenSyntax = {
            guard
                let labelList = LabeledExprListSyntax(node.arguments),
                let scopeArgument = labelList.first(where: {
                    $0.label?.trimmedDescription == "scope"
                }),
                let scopeExpr = MemberAccessExprSyntax(scopeArgument.expression),
                let scope = ScopeLevel(string: scopeExpr.declName.baseName.text)
            else {
                return "\(raw: ScopeLevel.internal.scope)"
            }

            return "\(raw: scope.scope)"
        }()

        let protocolName: TypeSyntax = "\(`protocol`.name.trimmed)"

        var result = [ExtensionDeclSyntax]()

        do {
            var `extension` = try ExtensionDeclSyntax("""
            \(scope) extension \(type) {}
            """)

            var members: MemberBlockItemListSyntax {
                get { `extension`.memberBlock.members }
                set { `extension`.memberBlock.members = newValue }
            }

            members.append(contentsOf: `protocol`.memberBlock.members)

            try buildRequirementsBodies(
                for: &members,
                baseName: "base_\(protocolName)",
                protocolName: protocolName,
                options: globalOptions
            )

            let base: DeclSyntax = """
            private var base_\(protocolName): any \(protocolName) {
                get {
                    base as! any \(protocolName)
                }
                set {
                    base = newValue as! _Base_
                }
            }
            """

            members.insert(.init(decl: base), at: members.startIndex)

            result.append(`extension`)
        }

        return result
    }
}
