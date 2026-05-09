import SwiftSyntax

// MARK: WithGenericArgumentsTypeSyntax

protocol WithGenericArgumentsTypeSyntax: TypeSyntaxProtocol {
    var genericArgumentClause: GenericArgumentClauseSyntax? { get set }
}

extension IdentifierTypeSyntax: WithGenericArgumentsTypeSyntax {}
extension MemberTypeSyntax: WithGenericArgumentsTypeSyntax {}

extension SyntaxProtocol {
    func asProtocol(_: (any WithGenericArgumentsTypeSyntax).Protocol) -> (any WithGenericArgumentsTypeSyntax)? {
        asSyntaxProtocol() as? WithGenericArgumentsTypeSyntax
    }
}

// MARK: - WithNameTypeSyntax

protocol WithNameTypeSyntax: TypeSyntaxProtocol {
    var name: TokenSyntax { get set }
}

extension IdentifierTypeSyntax: WithNameTypeSyntax {}
extension MemberTypeSyntax: WithNameTypeSyntax {}

extension SyntaxProtocol {
    func asProtocol(_: (any WithNameTypeSyntax).Protocol) -> (any WithNameTypeSyntax)? {
        asSyntaxProtocol() as? WithNameTypeSyntax
    }
}

// MARK: - WithMemberBlockSyntax

protocol WithMemberBlockDeclSyntax: DeclSyntaxProtocol {
    var memberBlock: MemberBlockSyntax { get set }
}

extension StructDeclSyntax: WithMemberBlockDeclSyntax {}
extension ClassDeclSyntax: WithMemberBlockDeclSyntax {}
extension EnumDeclSyntax: WithMemberBlockDeclSyntax {}
extension ActorDeclSyntax: WithMemberBlockDeclSyntax {}
extension ExtensionDeclSyntax: WithMemberBlockDeclSyntax {}

extension DeclSyntaxProtocol {
    func asProtocol(_: (any WithMemberBlockDeclSyntax).Protocol) -> (any WithMemberBlockDeclSyntax)? {
        asSyntaxProtocol() as? WithMemberBlockDeclSyntax
    }
}

// MARK: - Extra

extension SyntaxProtocol {
    func asSyntaxProtocol() -> SyntaxProtocol? {
        Syntax(self).asProtocol((any SyntaxProtocol).self)
    }
}
