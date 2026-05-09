import MultiModule
import SwiftSyntax
import SwiftSyntaxMacros

func generationCore(
    context _: some MacroExpansionContext,
    options globalOptions: TypeEraserOptions,
    protocol: ProtocolDeclSyntax,
    scope scopeLevel: ScopeLevel
) throws -> [DeclSyntax] {
    let protocolName: TypeSyntax = "\(`protocol`.name.trimmed)"
    let scope: TokenSyntax = "\(raw: scopeLevel.scope)"

    var constraints = try getWhereClauses(protocol: `protocol`)
    var associates = try getAssociates(`protocol`.memberBlock.members)

    var result = [DeclSyntax]()

    let conformances: [String]? = try {
        let inheritedTypes = `protocol`.inheritanceClause?
            .inheritedTypes.map(\.type)

        var result = [String]()

        func parse(type: TypeSyntax) {
            if let identifier = IdentifierTypeSyntax(type) {
                result.append(identifier.name.text)
            }

            if let composition = CompositionTypeSyntax(type) {
                for type in composition.elements.map(\.type) {
                    parse(type: type)
                }
            }
        }

        if let inheritedTypes {
            for type in inheritedTypes {
                parse(type: type)
            }
        }

        do {
            let selfConstraints = constraints.removeEverything { constraint in
                guard constraint.associateName.names.count == 1 else {
                    return false
                }

                return constraint.associateName.names.first == "Self"
            }

            let selfConformances = try selfConstraints
                .flatMap {
                    guard case let .conforms(conformance) = $0 else {
                        throw CompilerError("Self equals constraint")
                    }

                    return conformance.conformances
                }

            result.append(contentsOf: selfConformances)
        }

        do {
            let selfAssociates = associates.removeEverything {
                $0.name == "Self"
            }

            result.append(contentsOf: selfAssociates.flatMap(\.conformances))
        }

        return result.isEmpty ? nil : result.unique()
    }()

    let conformanceList = if let conformances, !globalOptions.contains(.disableEraserInheritance) {
        ", \(conformances.map { "Erased\($0)" }.joined(separator: ", "))"
    } else {
        ""
    }

    // MARK: Eraser Struct

    do {
        var eraser: StructDeclSyntax = try StructDeclSyntax("""
        /// A type erased `\(protocolName)` value.
        \(scope) struct Any\(protocolName): TypeEraser, Erased\(protocolName) {
            /// The value wrapped by this instance.
            \(scope) var base: any \(protocolName)
            /// Create an instance that type-erases `\(protocolName)`.
            \(scope) init(_ erasing: some \(protocolName)) {
                self.base = erasing
            }
            /// Create an instance that type-erases `\(protocolName)`.
            \(scope) init(erasing: any \(protocolName)) {
                self.base = erasing
            }
        }
        """)

        let erasers = try createNecessaryErasers(constraints).map {
            MemberBlockItemSyntax(decl: $0.decl(options: globalOptions))
        }

        eraser.memberBlock.members.append(contentsOf: erasers)

        result.append(DeclSyntax(eraser))
    }

    // MARK: Eraser Storage Enum

    do {
        let optionsArrayString = globalOptions._arrayDescription

        var `enum` = try EnumDeclSyntax("""
        \(scope) enum _ErasedStorage\(protocolName) {}
        """)

        var enumDecls = [DeclSyntax]()

        do {
            var associateDecls = [String]()

            for associate in associates {
                let clause = if associate.conformances.isEmpty {
                    ""
                } else {
                    ": \(associate.conformances.joined(separator: ", "))"
                }

                associateDecls.append("""
                associatedtype \(associate.name)\(clause) = \(associate.eraser)
                """)
            }

            enumDecls.append("""
            @__TEExtend(######\"\"\"\n\(`protocol`)\n\"\"\"######, options: \(raw: optionsArrayString), scope: \(raw: scopeLevel.accessSyntax))
            \(scope) protocol Erased\(protocolName): TypeEraser, \(protocolName)\(raw: conformanceList) { \(raw: associateDecls.joined(separator: "\n"))\n}
            """)
        }

        if globalOptions.contains(.selfGenerateCompositions) {
            for associate in associates {
                guard
                    associate.conformances.count > 1,
                    associate._eraser == nil
                else {
                    continue
                }

                let clause = associate.conformances
                    .map { "any \($0)" }
                    .joined(separator: ", ")

                enumDecls.append("""
                #compositionTypeEraser<\(raw: clause)>(options: [.disableCommutativity])
                """)
            }
        }

        `enum`.memberBlock.members.append(
            contentsOf: enumDecls.map { MemberBlockItemSyntax(decl: $0) }
        )

        result.append(DeclSyntax(`enum`))
    }

    result.append("""
    \(scope) typealias Erased\(protocolName) = _ErasedStorage\(protocolName).Erased\(protocolName)
    """)

    return result
}
