import SwiftSyntax

protocol WithGenericArgumentsTypeSyntax: TypeSyntaxProtocol {
    var genericArgumentClause: GenericArgumentClauseSyntax? { get set }
}

extension IdentifierTypeSyntax: WithGenericArgumentsTypeSyntax {}
extension MemberTypeSyntax: WithGenericArgumentsTypeSyntax {}

protocol WithNameTypeSyntax: TypeSyntaxProtocol {
    var name: TokenSyntax { get set }
}

extension IdentifierTypeSyntax: WithNameTypeSyntax {}
extension MemberTypeSyntax: WithNameTypeSyntax {}
