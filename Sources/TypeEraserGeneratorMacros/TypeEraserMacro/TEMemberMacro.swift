import SwiftSyntaxMacros
import SwiftSyntax
import MultiModule
import Foundation

extension TypeEraserMacro: MemberMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let prot: ProtocolDeclSyntax

        do {
            prot = try getRawProtocol(from: declaration, node: node)
        } catch {
            return []
        }

        let globalOptions = try getOptionsFromTypeEraser(node: node)

        var members = [DeclSyntax]()

        members.insert("""
        /// Used for automatically resolving the type of `Erase` macro.
        typealias _Eraser_ = Any\(prot.name)
        """, at: members.startIndex)

        var newDecls = prot.memberBlock.members.map(\.decl)

        var pendingRemovalIndexes = [Int]()

        try transform(&newDecls) { index, decl in
            let localOptions = try getOptionsFromDecl(decl: decl)

            let options = globalOptions.union(localOptions)

            guard options.contains(.exportStaticToObjectLevel) else {
                pendingRemovalIndexes.append(index)
                throw LoopWorkflow.continue
            }

            guard let nonStaticDecl = checkStaticAndReturnNonStatic(decl) else {
                pendingRemovalIndexes.append(index)
                throw LoopWorkflow.continue
            }

            decl = nonStaticDecl

            removeHelperMacros(&decl)
        }

        newDecls.remove(bulk: pendingRemovalIndexes)

        return members
    }
}
