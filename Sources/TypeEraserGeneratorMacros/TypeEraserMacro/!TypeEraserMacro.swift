import Foundation
import MultiModule
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum TypeEraserMacro {
    static func getRawProtocol(
        from decl: some DeclSyntaxProtocol,
        node: AttributeSyntax
    ) throws -> ProtocolDeclSyntax {
        guard var prot = ProtocolDeclSyntax(decl) else {
            throw ExpansionError.protocolsOnly
        }

        prot.attributes.remove { element in
            element.trimmedDescription == node.trimmedDescription
        }

        return prot
    }

    static func getOptionsFromSomeDecl(
        decl: some WithAttributesSyntax
    ) throws -> TypeEraserOptions {
        guard
            let erasingOptions = decl.attributes
                .compactMap(AttributeSyntax.init)
                .first(where: {
                    $0.attributeName.trimmedDescription
                        .prefix(while: \.isLetter) == "ErasingOptions"
                })
        else {
            return []
        }

        return try getOptionsFromErasingOptions(node: erasingOptions)
    }

    static func getOptionsFromDecl(
        decl: DeclSyntax
    ) throws -> TypeEraserOptions {
        guard
            let decl = decl.asProtocol((any WithAttributesSyntax).self),
            let erasingOptions = decl.attributes
                .compactMap(AttributeSyntax.init)
                .first(where: {
                    $0.attributeName.trimmedDescription
                        .prefix(while: \.isLetter) == "ErasingOptions"
                })
        else {
            return []
        }

        return try getOptionsFromErasingOptions(node: erasingOptions)
    }

    static func getOptionsFromErasingOptions(
        node: AttributeSyntax
    ) throws -> TypeEraserOptions {
        func getOption(expression: ExprSyntax) throws -> TypeEraserOptions? {
            guard let access = MemberAccessExprSyntax(expression) else {
                return nil
            }

            guard let option = TypeEraserOptions(
                string: access.declName.trimmedDescription
            ) else {
                throw ExpansionError.internalError("No options match")
            }

            return option
        }

        guard
            let labelList = LabeledExprListSyntax(node.arguments),
            let optionArgument = labelList.first
        else {
            return []
        }

        if let option = try getOption(expression: optionArgument.expression) {
            return option
        }

        guard let array = ArrayExprSyntax(optionArgument.expression) else {
            throw ExpansionError.incorrectOptions
        }

        let options = try array.elements
            .map(\.expression)
            .map { expr in
                guard let option = try getOption(expression: expr) else {
                    throw ExpansionError.incorrectOptions
                }
                return option
            }

        return options.reduce([]) { $0.union($1) }
    }

    static func getOptionsFromTypeEraser(
        node: AttributeSyntax
    ) throws -> TypeEraserOptions {
        func getOption(expression: ExprSyntax) throws -> TypeEraserOptions? {
            guard let access = MemberAccessExprSyntax(expression) else {
                return nil
            }

            guard let option = TypeEraserOptions(
                string: access.declName.trimmedDescription
            ) else {
                throw ExpansionError.internalError("No options match")
            }

            return option
        }

        guard
            let labelList = LabeledExprListSyntax(node.arguments),
            let optionArgument = labelList.first(where: {
                $0.label?.trimmedDescription == "options"
            })
        else {
            return []
        }

        if let option = try getOption(expression: optionArgument.expression) {
            return option
        }

        guard let array = ArrayExprSyntax(optionArgument.expression) else {
            throw ExpansionError.incorrectOptions
        }

        let options = try array.elements
            .map(\.expression)
            .map { expr in
                guard let option = try getOption(expression: expr) else {
                    throw ExpansionError.incorrectOptions
                }
                return option
            }

        return options.reduce([]) { $0.union($1) }
    }

    static func removeHelperMacros(_ syntax: inout DeclSyntax) {
        var attributedSyntax: any WithAttributesSyntax {
            get { syntax.asProtocol((any WithAttributesSyntax).self)! }
            set { syntax = "\(newValue)" }
        }

        attributedSyntax.attributes.remove { attribute in
            guard let attribute = AttributeSyntax(attribute) else {
                return false
            }

            return helperMacroNames.contains(attribute.name)
        }
    }

    static func checkStaticAndReturnNonStatic(
        _ syntax: DeclSyntax
    ) -> DeclSyntax? {
        if syntax.is(InitializerDeclSyntax.self) ||
            syntax.is(TypeAliasDeclSyntax.self) ||
            syntax.is(AssociatedTypeDeclSyntax.self) {
            return nil
        }

        guard
            var syntax = syntax.asProtocol((any WithModifiersSyntax).self),
            syntax.isStatic
        else { return nil }

        syntax.modifiers.remove { syntax in
            syntax.name.trimmedDescription == "static"
        }

        return DeclSyntax(syntax)
    }
}

let staticInaccessibleFatalError: ExprSyntax = #"""
fatalError("Tried to access static member \(#function) from type eraser")
"""#

enum StaticImplementationType {
    case value(TokenSyntax)
    case type(TokenSyntax)
    case external
    case error
}
