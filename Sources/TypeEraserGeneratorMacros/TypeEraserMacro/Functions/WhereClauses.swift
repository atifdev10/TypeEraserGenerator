import SwiftSyntax

struct AssociateChain {
    var names: [String] = []
}

struct WhereConformanceRequirement {
    var associateName: AssociateChain
    var conformances: [String]
}

struct WhereEqualRequirement {
    var associateName: AssociateChain
    var equal: String
}

enum WhereRequirement {
    case conforms(WhereConformanceRequirement)
    case equals(WhereEqualRequirement)

    var associateName: AssociateChain {
        get {
            switch self {
            case let .conforms(requirement): requirement.associateName
            case let .equals(requirement): requirement.associateName
            }
        }
        set {
            switch self {
            case var .conforms(requirement):
                requirement.associateName = newValue
                self = .conforms(requirement)
            case var .equals(requirement):
                requirement.associateName = newValue
                self = .equals(requirement)
            }
        }
    }
}

private func getWhereClausesCore(
    _ clauses: [GenericWhereClauseSyntax]
) throws -> [WhereRequirement] {
    var result = [WhereRequirement]()

    for clause in clauses {
        let requirements = clause.requirements.map(\.requirement)

        for case let .conformanceRequirement(conformance) in requirements {
            var chain = AssociateChain()
            var type: TypeSyntax = conformance.leftType

            while let member = MemberTypeSyntax(type) {
                chain.names.insert(member.name.text, at: 0)

                type = member.baseType
            }

            let identifier = IdentifierTypeSyntax(type)!
            chain.names.insert(identifier.name.text, at: 0)

            result.append(.conforms(.init(
                associateName: chain,
                conformances: conformance.rightType.trimmedDescription
                    .replacingOccurrences(of: " & ", with: "&")
                    .replacingOccurrences(of: "& ", with: "&")
                    .components(separatedBy: "&")
            )))
        }

        for case let .sameTypeRequirement(equal) in requirements {
            var chain = AssociateChain()
            var type: TypeSyntax = equal.leftType.as(TypeSyntax.self)!

            while let member = MemberTypeSyntax(type) {
                chain.names.insert(member.name.text, at: 0)

                type = member.baseType
            }

            let identifier = IdentifierTypeSyntax(type)!
            chain.names.insert(identifier.name.text, at: 0)

            result.append(.equals(.init(
                associateName: chain,
                equal: equal.rightType.trimmedDescription
            )))
        }
    }

    try! transform(&result) { element in
        guard
            element.associateName.names.count > 1,
            element.associateName.names[0] == "Self"
        else {
            throw LoopWorkflow.continue
        }

        element.associateName.names.removeFirst()
    }

    return result
}

func getWhereClauses(
    protocol: ProtocolDeclSyntax
) throws -> [WhereRequirement] {
    var clauses = [GenericWhereClauseSyntax]()

    if let clause = `protocol`.genericWhereClause {
        clauses.append(clause)
    }

    let associatedGenericClauses = `protocol`.memberBlock.members
        .map(\.decl)
        .compactMap(AssociatedTypeDeclSyntax.init)
        .compactMap(\.genericWhereClause)

    clauses.append(contentsOf: associatedGenericClauses)

    return try getWhereClausesCore(clauses)
}
