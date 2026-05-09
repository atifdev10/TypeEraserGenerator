import MultiModule
import SwiftSyntax

func getOptions(node: AttributeSyntax) throws -> TypeEraserOptions {
    guard let arguments = node.arguments else {
        return []
    }

    return try getOptionsCore(nodeArguments: arguments)
}

func getOptions(node: some FreestandingMacroExpansionSyntax) throws -> TypeEraserOptions {
    try getOptionsCore(nodeArguments: node.arguments)
}

private func getOptionsCore(nodeArguments: some SyntaxProtocol) throws -> TypeEraserOptions {
    func getOption(expression: ExprSyntax) throws -> TypeEraserOptions? {
        guard let access = MemberAccessExprSyntax(expression) else {
            return nil
        }

        guard let option = TypeEraserOptions(
            string: access.declName.trimmedDescription
        ) else {
            throw InternalError("No options match")
        }

        return option
    }

    guard
        let labelList = LabeledExprListSyntax(nodeArguments),
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
        throw IndirectOptionAccessError()
    }

    let options = try array.elements
        .map(\.expression)
        .map { expr in
            guard let option = try getOption(expression: expr) else {
                throw IndirectOptionAccessError()
            }
            return option
        }

    return options.reduce([]) { $0.union($1) }
}

func getOptions(decl: DeclSyntax) throws -> TypeEraserOptions {
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

func getOptions(decl: some WithAttributesSyntax) throws -> TypeEraserOptions {
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

private func getOptionsFromErasingOptions(
    node: AttributeSyntax
) throws -> TypeEraserOptions {
    func getOption(expression: ExprSyntax) throws -> TypeEraserOptions? {
        guard let access = MemberAccessExprSyntax(expression) else {
            return nil
        }

        guard let option = TypeEraserOptions(
            string: access.declName.trimmedDescription
        ) else {
            throw InternalError("No options match")
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
        throw IndirectOptionAccessError()
    }

    let options = try array.elements
        .map(\.expression)
        .map { expr in
            guard let option = try getOption(expression: expr) else {
                throw IndirectOptionAccessError()
            }
            return option
        }

    return options.reduce([]) { $0.union($1) }
}
