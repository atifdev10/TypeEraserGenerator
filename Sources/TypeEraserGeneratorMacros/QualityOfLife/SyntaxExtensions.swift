import Foundation
import SwiftSyntax

extension WithModifiersSyntax {
    var isStatic: Bool {
        if `is`(InitializerDeclSyntax.self) ||
            `is`(AssociatedTypeDeclSyntax.self) {
            return true
        }

        return modifiers.map(\.name.trimmedDescription)
            .contains("static")
    }
}

extension WithAttributesSyntax {
    var attributeNames: [String] {
        attributes.compactMap(AttributeSyntax.init).map(\.name)
    }
}

extension AttributeSyntax {
    var name: String {
        String(attributeName.trimmedDescription.prefix(while: \.isLetter))
    }
}

extension FunctionDeclSyntax {
    var isThrowing: Bool {
        guard let throwsClause = signature.effectSpecifiers?.throwsClause else {
            return false
        }

        return throwsClause.type?.trimmedDescription != "Never"
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

    var containsInoutParameter: Bool {
        signature.parameterClause.parameters.contains { parameter in
            AttributedTypeSyntax(parameter.type)?.specifiers
                .compactMap(SimpleTypeSpecifierSyntax.init)
                .contains {
                    $0.specifier.trimmedDescription == "inout"
                } ?? false
        }
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

    mutating func fillEmptyInputParametersIfNeeded() {
        transform(&signature.parameterClause.parameters) { index, parameter in
            guard
                parameter.secondName?.trimmedDescription == any(of: nil, "_"),
                parameter.firstName.trimmedDescription == "_"
            else {
                return
            }

            let wasSecondNameNil = parameter.secondName == nil

            parameter.secondName = "param\(raw: index.integer)"

            parameter.secondName!.leadingTrivia = wasSecondNameNil ? " " : ""
        }
    }

    var parameterInputs: [String] {
        signature.parameterClause.parameters.map { parameter in
            if let secondName = parameter.secondName,
               secondName.trimmedDescription != "_" {
                return secondName.trimmedDescription
            }

            if parameter.firstName.trimmedDescription != "_" {
                return parameter.firstName.trimmedDescription
            }

            return "error"
        }
    }

    func formattedParameters(
        transformer: (_ input: String) -> String = { $0 }
    ) -> String {
        zip(parameterLabels, parameterInputs)
            .map { label, input in
                guard let label else {
                    return transformer(input)
                }

                return label + ":" + transformer(input)
            }
            .joined(separator: ", ")
    }
}

extension InitializerDeclSyntax {
    var isThrowing: Bool {
        guard let throwsClause = signature.effectSpecifiers?.throwsClause else {
            return false
        }

        return throwsClause.type?.trimmedDescription != "Never"
    }

    var isAsync: Bool {
        signature.effectSpecifiers?.asyncSpecifier != nil
    }

    var isOptional: Bool {
        optionalMark != nil
    }

    var containsInoutParameter: Bool {
        signature.parameterClause.parameters.contains { parameter in
            AttributedTypeSyntax(parameter.type)?.specifiers
                .compactMap(SimpleTypeSpecifierSyntax.init)
                .contains {
                    $0.specifier.trimmedDescription == "inout"
                } ?? false
        }
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

    mutating func fillEmptyInputParametersIfNeeded() {
        transform(&signature.parameterClause.parameters) { index, parameter in
            guard
                parameter.secondName?.trimmedDescription == any(of: nil, "_"),
                parameter.firstName.trimmedDescription == "_"
            else {
                return
            }

            let wasSecondNameNil = parameter.secondName == nil

            parameter.secondName = "param\(raw: index.integer)"

            parameter.secondName!.leadingTrivia = wasSecondNameNil ? " " : ""
        }
    }

    var parameterInputs: [String] {
        signature.parameterClause.parameters.map { parameter in
            if let secondName = parameter.secondName,
               secondName.trimmedDescription != "_" {
                return secondName.trimmedDescription
            }

            if parameter.firstName.trimmedDescription != "_" {
                return parameter.firstName.trimmedDescription
            }

            return "error"
        }
    }

    func formattedParameters(
        transformer: (_ input: String) -> String = { $0 }
    ) -> String {
        zip(parameterLabels, parameterInputs)
            .map { label, input in
                guard let label else {
                    return transformer(input)
                }

                return label + ":" + transformer(input)
            }
            .joined(separator: ", ")
    }
}

extension SubscriptDeclSyntax {
    var isThrowing: Bool {
        guard
            let accessors = AccessorDeclListSyntax(accessorBlock?.accessors),
            let throwsClause = accessors.first?.effectSpecifiers?.throwsClause
        else {
            return false
        }

        return throwsClause.type?.trimmedDescription != "Never"
    }

    var isAsync: Bool {
        AccessorDeclListSyntax(accessorBlock?.accessors)?.first?
            .effectSpecifiers?
            .asyncSpecifier != nil
    }

    var containsInoutParameter: Bool {
        parameterClause.parameters.contains { parameter in
            AttributedTypeSyntax(parameter.type)?.specifiers
                .compactMap(SimpleTypeSpecifierSyntax.init)
                .contains {
                    $0.specifier.trimmedDescription == "inout"
                } ?? false
        }
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

    mutating func fillEmptyInputParametersIfNeeded() {
        transform(&parameterClause.parameters) { index, parameter in
            let condition = if parameter.secondName != nil {
                parameter.secondName?.trimmedDescription == "_"
            } else {
                parameter.firstName.trimmedDescription == "_"
            }

            guard condition else {
                return
            }

            let wasSecondNameNil = parameter.secondName == nil

            parameter.secondName = "param\(raw: index.integer)"

            parameter.secondName!.leadingTrivia = wasSecondNameNil ? " " : ""
        }
    }

    var parameterInputs: [String] {
        parameterClause.parameters.map { parameter in
            guard let secondName = parameter.secondName else {
                return parameter.firstName.trimmedDescription
            }

            return secondName.trimmedDescription
        }
    }

    func formattedParameters(
        transformer: (_ input: String) -> String = { $0 }
    ) -> String {
        zip(parameterLabels, parameterInputs)
            .map { label, input in
                guard let label else {
                    return transformer(input)
                }

                return label + ":" + transformer(input)
            }
            .joined(separator: ", ")
    }

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

extension SyntaxChildrenIndex {
    var integer: Int {
        guard let child = Mirror(reflecting: self).children.first else {
            fatalError()
        }

        return child.value as! Int
    }
}

func withDeclSyntaxCast<E: Error, T: DeclSyntaxProtocol>(
    _ decl: inout DeclSyntax,
    to _: T.Type,
    _ block: (inout T) throws(E) -> Void
) throws(E) {
    var castedDecl: T {
        get { decl.cast(T.self) }
        set { decl = DeclSyntax(newValue) }
    }

    try block(&castedDecl)
}
