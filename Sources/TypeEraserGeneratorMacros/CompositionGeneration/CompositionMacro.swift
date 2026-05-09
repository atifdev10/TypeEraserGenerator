import Algorithms
import Foundation
import MultiModule
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum CompositionMacro: DeclarationMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let genericArgumentClause = node.genericArgumentClause else {
            return []
        }

        var options = try getCompositionOptions(node: node)

        var result = [DeclSyntax]()

        let conformanceStrings = try {
            var conformances = [TypeSyntax]()

            let arguments = genericArgumentClause.arguments.map(\.argument)
            for case let .type(type) in arguments {
                guard let anySyntax = SomeOrAnyTypeSyntax(type) else {
                    throw ProtocolAnyPrefixError()
                }

                conformances.append(anySyntax.constraint)
            }

            return conformances.map(\.trimmedDescription)
        }()

        guard conformanceStrings.count > 1 else {
            throw MacroError("Cannot have a composition with a single protocol")
        }

        if conformanceStrings.count > 6, !options.contains(.disableCommutativity) {
            context.diagnose(Diagnostic(
                node: node, message: MacroExpansionWarningMessage(
                    "Commutativity overloaded, automatically disabled commutativity"
                )
            ))
            options.insert(.disableCommutativity)
        }

        let composition = conformanceStrings.joined(separator: "&")
        let name = conformanceStrings.joined(separator: "And")
        let conformanceList = conformanceStrings
            .map { "Erased" + $0 }
            .joined(separator: ",")

        result.append("""
        struct Any\(raw: name): TypeEraser, \(raw: conformanceList) {
            /// The value wrapped by this instance.
            var base: any \(raw: composition)
            /// Create an instance that type-erases `\(raw: composition)`.
            init(_ erasing: some \(raw: composition)) {
                self.base = erasing
            }
            /// Create an instance that type-erases `\(raw: composition)`.
            init(erasing: any \(raw: composition)) {
                self.base = erasing
            }
        }
        """)

        if !options.contains(.disableCommutativity) {
            var possibilities = conformanceStrings.permutations().map(\.self)
            possibilities.removeAll { $0 == conformanceStrings }

            for possibility in possibilities {
                result.append("""
                typealias Any\(raw: possibility.joined(separator: "And")) = Any\(raw: name)
                """)
            }
        }

        return result
    }
}

private func getCompositionOptions(node: some FreestandingMacroExpansionSyntax) throws -> CompositionOptions {
    func getOption(expression: ExprSyntax) throws -> CompositionOptions? {
        guard let access = MemberAccessExprSyntax(expression) else {
            return nil
        }

        guard let option = CompositionOptions(
            string: access.declName.trimmedDescription
        ) else {
            throw InternalError("No options match")
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
