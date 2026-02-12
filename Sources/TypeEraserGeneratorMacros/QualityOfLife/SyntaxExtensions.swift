import Foundation
import SwiftSyntax

extension WithModifiersSyntax {
    var isStatic: Bool {
        if `is`(InitializerDeclSyntax.self) {
            return true
        }

        return modifiers.map(\.name.trimmedDescription)
            .contains("static")
    }
}

extension FunctionDeclSyntax {
    var isThrowing: Bool {
        signature.effectSpecifiers?.throwsClause != nil &&
            signature.effectSpecifiers?.throwsClause?.type?.trimmedDescription != "Never"
    }

    var isAsync: Bool {
        signature.effectSpecifiers?.asyncSpecifier != nil
    }

    var isMutating: Bool {
        modifiers.contains { $0.name.trimmedDescription == "mutating" }
    }

    var returnType: TypeSyntax {
        signature.returnClause?.type ?? "Void"
    }

    var parameterLabels: [String?] {
        signature.parameterClause.parameters.map { parameter in
            if parameter.firstName.trimmedDescription == "_" {
                nil
            } else {
                parameter.firstName.trimmedDescription
            }
        }
    }

    mutating func getParameterInputsAndFillEmpty() -> [String] {
        var inputs = [String]()

        transform(&signature.parameterClause.parameters) { _, parameter in
            if let secondName = parameter.secondName,
               secondName.trimmedDescription != "_" {
                inputs.append(secondName.trimmedDescription)
            } else if parameter.firstName.trimmedDescription != "_" {
                inputs.append(parameter.firstName.trimmedDescription)
            } else {
                let generated: TokenSyntax = "param\(raw: inputs.count)"
                parameter.secondName = generated
                inputs.append(generated.trimmedDescription)
            }
        }

        return inputs
    }
}

extension InitializerDeclSyntax {
    var isThrowing: Bool {
        signature.effectSpecifiers?.throwsClause != nil &&
            signature.effectSpecifiers?.throwsClause?.type?.trimmedDescription != "Never"
    }

    var isAsync: Bool {
        signature.effectSpecifiers?.asyncSpecifier != nil
    }

    var isOptional: Bool {
        optionalMark != nil
    }

    var parameterLabels: [String?] {
        signature.parameterClause.parameters.map { parameter in
            if parameter.firstName.trimmedDescription == "_" {
                nil
            } else {
                parameter.firstName.trimmedDescription
            }
        }
    }

    mutating func getParameterInputsAndFillEmpty() -> [String] {
        var inputs = [String]()

        transform(&signature.parameterClause.parameters) { _, parameter in
            if let secondName = parameter.secondName,
               secondName.trimmedDescription != "_" {
                inputs.append(secondName.trimmedDescription)
            } else if parameter.firstName.trimmedDescription != "_" {
                inputs.append(parameter.firstName.trimmedDescription)
            } else {
                let generated: TokenSyntax = "param\(raw: inputs.count)"
                parameter.secondName = generated
                inputs.append(generated.trimmedDescription)
            }
        }

        return inputs
    }
}

extension SubscriptDeclSyntax {
    var isThrowing: Bool {
        accessorBlock?.accessors
            .as(AccessorDeclListSyntax.self)?
            .first?
            .effectSpecifiers?
            .throwsClause != nil &&
            accessorBlock?.accessors
            .as(AccessorDeclListSyntax.self)?
            .first?
            .effectSpecifiers?
            .throwsClause?
            .type?
            .trimmedDescription != "Never"
    }

    var isAsync: Bool {
        accessorBlock?.accessors
            .as(AccessorDeclListSyntax.self)?
            .first?
            .effectSpecifiers?
            .asyncSpecifier != nil
    }

    var parameterLabels: [String?] {
        parameterClause.parameters.map { parameter in
            guard
                parameter.secondName != nil,
                parameter.firstName.trimmedDescription != "_"
            else {
                return nil
            }

            return parameter.firstName.trimmedDescription
        }
    }

    mutating func getParameterInputsAndFillEmpty() -> [String] {
        var inputs = [String]()

        transform(&parameterClause.parameters) { _, parameter in
            guard let secondName = parameter.secondName else {
                if parameter.firstName.trimmedDescription == "_" {
                    let generated: TokenSyntax = """
                    param\(raw: inputs.count)
                    """

                    parameter.secondName = generated
                    inputs.append(generated.trimmedDescription)
                } else {
                    inputs.append(parameter.firstName.trimmedDescription)
                }
                return
            }

            if secondName.trimmedDescription == "_" {
                let generated: TokenSyntax = "param\(raw: inputs.count)"
                parameter.secondName = generated
                inputs.append(generated.trimmedDescription)
            } else {
                inputs.append(secondName.trimmedDescription)
            }
        }

        return inputs
    }
}

extension SubscriptDeclSyntax {
    var returnType: TypeSyntax {
        returnClause.type
    }
}

extension AccessorDeclSyntax {
    var isThrowing: Bool {
        effectSpecifiers?.throwsClause != nil
    }

    var isAsync: Bool {
        effectSpecifiers?.asyncSpecifier != nil
    }

    var isMutating: Bool {
        switch accessorSpecifier.trimmedDescription {
        case "get":
            modifier?.trimmedDescription == "mutating"
        case "set":
            modifier?.trimmedDescription != "nonmutating"
        default:
            fatalError()
        }
    }
}
