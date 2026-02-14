import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct TypeEraserOptions: OptionSet, Sendable {
    let rawValue: UInt

    init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    static let exportStaticRequirements = TypeEraserOptions(rawValue: 1 << 0)
}

enum TypeEraserMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let `protocol` = try getRawProtocol(from: declaration, node: node)
        var `struct` = convertProtocolToStruct(`protocol`)

        let protocolName: TokenSyntax =
            "\(raw: `protocol`.name.trimmedDescription)"

        `struct`.name = "Any\(raw: `struct`.name.trimmedDescription)"
        `struct`.genericParameterClause = nil

        var members: MemberBlockItemListSyntax {
            get { `struct`.memberBlock.members }
            set { `struct`.memberBlock.members = newValue }
        }

        var associates = try stripAssociates(&members, node: node)

        try transform(&members, access: \.decl) { _, decl in
            switch decl.kind {
            case .functionDecl:
                var function: FunctionDeclSyntax {
                    get { decl.cast(FunctionDeclSyntax.self) }
                    set { decl = DeclSyntax(newValue) }
                }

                try addImplementationToFunction(
                    &function,
                    node: node,
                    protocolName: protocolName
                )

            case .variableDecl:
                var variable: VariableDeclSyntax {
                    get { decl.cast(VariableDeclSyntax.self) }
                    set { decl = DeclSyntax(newValue) }
                }

                try addImplementationToVariable(
                    &variable,
                    node: node,
                    protocolName: protocolName
                )

            case .subscriptDecl:
                var `subscript`: SubscriptDeclSyntax {
                    get { decl.cast(SubscriptDeclSyntax.self) }
                    set { decl = DeclSyntax(newValue) }
                }

                try addImplementationToSubscript(
                    &`subscript`,
                    node: node,
                    protocolName: protocolName
                )

            case .initializerDecl:
                var initializer: InitializerDeclSyntax {
                    get { decl.cast(InitializerDeclSyntax.self) }
                    set { decl = DeclSyntax(newValue) }
                }

                try addImplementationToInit(
                    &initializer,
                    node: node,
                    protocolName: protocolName
                )

            case .associatedTypeDecl: break
            case .typeAliasDecl: break

            default:
                throw ExpansionError.notSupportedDecl(kind: decl.kind)
            }

            decl = trimDefaultMacros(decl)!
            decl = decl.indented(by: .tab)
            decl = decl.trimmed
        }

        // TODO: Add type checking for defaults

        let boilerplateDecls: [DeclSyntax] = [
            """
            var base: any \(protocolName)
            """,
            """
            init(_ erasing: some \(protocolName)) {
                self.base = erasing
            }
            """,
            """
            init(erasing: any \(protocolName)) {
                self.base = erasing
            }
            """,
        ]

        let items = boilerplateDecls.map { MemberBlockItemSyntax(decl: $0) }

        members.insert(contentsOf: items, at: members.startIndex)

        let inheritances = InheritedTypeListSyntax {
            `protocol`.inheritanceClause?.inheritedTypes.map(\.self) ?? []
        }

        for inheritance in inheritances {
            if let type = inheritance.type.as(IdentifierTypeSyntax.self) {
                try addConformanceRequirements(
                    type, `protocol`, &members, &associates
                )
            }

            if let type = inheritance.type.as(MemberTypeSyntax.self) {
                try addConformanceRequirements(
                    type, `protocol`, &members, &associates
                )
            }
        }

        for associate in associates.sorted(by: { $0.key > $1.key }) {
            let aliasDecl: DeclSyntax = """
            typealias \(raw: associate.key) = \(raw: associate.value)
            """

            members.insert(
                .init(decl: aliasDecl),
                at: members.startIndex
            )
        }

        return [DeclSyntax(`struct`)]
    }

    static func getRawProtocol(
        from decl: some DeclSyntaxProtocol,
        node: AttributeSyntax
    ) throws -> ProtocolDeclSyntax {
        guard var prot = ProtocolDeclSyntax(decl) else {
            throw ExpansionError.protocolsOnly
        }

        prot.attributes = prot.attributes
            .filter { element in
                element
                    .as(AttributeSyntax.self)?
                    .attributeName
                    .as(IdentifierTypeSyntax.self)!.name.text !=
                    node.attributeName
                    .as(IdentifierTypeSyntax.self)!.name.text
            }
        return prot
    }

    static func convertProtocolToStruct(
        _ prot: ProtocolDeclSyntax
    ) -> StructDeclSyntax {
        var toBeStruct = prot
        var protocolKeyword = prot.protocolKeyword
        var leadingTrivia = protocolKeyword.leadingTrivia
        var trailingTrivia = protocolKeyword.trailingTrivia
        toBeStruct.protocolKeyword = "struct"
        toBeStruct.protocolKeyword.leadingTrivia = leadingTrivia
        toBeStruct.protocolKeyword.trailingTrivia = trailingTrivia

        let decl: DeclSyntax = "\(raw: toBeStruct)"

        let conformance = InheritanceClauseSyntax(
            inheritedTypes: .init {
                InheritedTypeSyntax(
                    type: "\(raw: prot.name.trimmedDescription)" as TypeSyntax
                )
                InheritedTypeSyntax(type: "TypeEraser" as TypeSyntax)
            }
        )

        return decl.cast(StructDeclSyntax.self)
            .with(\.inheritanceClause, conformance)
    }

    static func addConformanceRequirements(
        _ inheritance: some WithGenericArgumentsTypeSyntax & WithNameTypeSyntax,
        _ protocol: ProtocolDeclSyntax,
        _ members: inout MemberBlockItemListSyntax,
        _ associates: inout [String: String]
    ) throws {
        switch inheritance.name.trimmedDescription {
        case "Identifiable":
            let value: String? = if let assoc = associates["ID"] {
                assoc
            } else if let generic = inheritance.genericArgumentClause?
                .arguments.first?.argument {
                "\(generic)"
            } else if
                let clauses = `protocol`.genericWhereClause?
                .requirements.compactMap({
                    $0.requirement.as(SameTypeRequirementSyntax.self)
                }),
                let clause = clauses.first(
                    where: {
                        $0.leftType.trimmedDescription == "ID" ||
                            $0.leftType.trimmedDescription == "Self.ID"
                    }
                ) {
                "\(clause.rightType)"
            } else {
                members.compactMap { member -> String? in
                    guard
                        let variable = member.decl
                        .as(VariableDeclSyntax.self),
                        let binding = variable.bindings.first,
                        binding.pattern
                        .as(IdentifierPatternSyntax.self)?
                        .identifier.text == "id"
                    else {
                        return nil
                    }

                    return "\(binding.typeAnnotation!.type)"
                }.first
            }

            guard let value else {
                throw ExpansionError.assocMustHaveAErasureSpecifier(assoc: "ID")
            }

            associates["ID"] = value

            let variableNames = members
                .compactMap {
                    $0.decl.as(VariableDeclSyntax.self)?.bindings
                        .compactMap {
                            $0.pattern.as(IdentifierPatternSyntax.self)
                        }
                }
                .flatMap(\.self)
                .map(\.identifier.text)

            if !variableNames.contains("id") {
                members.append(.init(decl: """
                var id: ID { self.base.id }
                """ as DeclSyntax))
            }

        case "Hashable":
            members.append(.init(decl: """
            func hash(into hasher: inout Hasher) {
                hasher.combine(base)
            }
            """ as DeclSyntax))

            fallthrough

        case "Equatable":
            members.append(.init(decl: """
            static func == (left: Self, right: Self) -> Bool {
                return _isEqual(lhs: left.base, rhs: right.base)
            }
            """ as DeclSyntax))

            members.append(.init(decl: """
            private static func _isEqual<T: Equatable, U: Equatable>(lhs: T, rhs: U) -> Bool {
                if let rhsAsT = rhs as? T { return lhs == rhsAsT }
                if let lhsAsU = lhs as? U { return lhsAsU == rhs }
                return false
            }
            """ as DeclSyntax))

        default:
            break
        }
    }

    static func getOptions(node: AttributeSyntax) throws -> TypeEraserOptions {
        func getFromName(
            _ input: DeclReferenceExprSyntax
        ) throws -> TypeEraserOptions {
            switch input.trimmedDescription {
            case "exportStaticRequirements":
                .exportStaticRequirements
            default:
                throw ExpansionError.internalError("No options match")
            }
        }

        return try (
            node.arguments?
                .as(LabeledExprListSyntax.self)?
                .compactMap { expr -> TypeEraserOptions? in
                    guard expr.label?.trimmedDescription == "options" else {
                        return nil
                    }

                    if let access = expr.expression.as(MemberAccessExprSyntax.self) {
                        return try getFromName(access.declName)
                    }

                    if let array = expr.expression.as(ArrayExprSyntax.self) {
                        return try array.elements.map { element in
                            guard let access = element.expression
                                .as(MemberAccessExprSyntax.self) else {
                                throw ExpansionError.incorrectOptions
                            }

                            return try getFromName(access.declName)
                        }.reduce(
                            into: [] as TypeEraserOptions
                        ) { partialResult, result in
                            partialResult.formUnion(result)
                        }
                    }

                    throw ExpansionError.incorrectOptions
                } ?? []
        ).reduce([] as TypeEraserOptions) { partialResult, new in
            partialResult.union(new)
        }
    }

    static func stripAssociates(
        _ members: inout MemberBlockItemListSyntax,
        node _: AttributeSyntax
    ) throws -> [String: String] {
        var associates = [String: String]()

        members = try members.filter { decl in
            guard let associated = AssociatedTypeDeclSyntax(decl.decl) else {
                return true
            }

            let attribute = try associated.attributes.compactMap { attribute in
                guard
                    let attribute = attribute.as(AttributeSyntax.self),
                    let name = attribute.attributeName.as(IdentifierTypeSyntax.self)
                else {
                    return StaticImplType.fatalError
                }

                switch name.name.trimmedDescription {
                case "ErasureType":
                    guard
                        let generic = name.genericArgumentClause?
                        .arguments.first
                    else {
                        throw ExpansionError.compilerError("No generic found")
                    }

                    let argument = if generic.argument.trimmedDescription == "AnyError" {
                        GenericArgumentSyntax.Argument.type("any Error")
                    } else {
                        generic.argument
                    }

                    return StaticImplType.type("\(argument)")
                default:
                    return nil
                }
            }.first

            switch attribute {
            case let .type(type):
                associates[associated.name.trimmedDescription] = type.trimmedDescription
            default:
                throw ExpansionError
                    .assocMustHaveAErasureSpecifier(assoc: associated.name.text)
            }

            return false
        }

        return associates
    }

    static func addImplementationToFunction(
        _ function: inout FunctionDeclSyntax,
        node: AttributeSyntax,
        protocolName: TokenSyntax,
        staticBase: TokenSyntax? = nil
    ) throws {
        var parameters: FunctionParameterListSyntax {
            get { function.signature.parameterClause.parameters }
            set { function.signature.parameterClause.parameters = newValue }
        }

        let labels = function.parameterLabels
        let inputs = function.getParameterInputsAndFillEmpty()

        let formattedParameters = zip(labels, inputs)
            .map { label, input in
                guard let label else {
                    return "__implicitCast(\(input))"
                }

                return "\(label): __implicitCast(\(input))"
            }
            .joined(separator: ", ")

        let formattedParametersPure = zip(labels, inputs)
            .map { label, input in
                guard let label else {
                    return "\(input)"
                }

                return "\(label): \(input)"
            }
            .joined(separator: ", ")

        let containsInout = function.signature.parameterClause.parameters
            .contains { a in
                a.type.as(AttributedTypeSyntax.self)?
                    .specifiers
                    .contains {
                        $0.as(SimpleTypeSpecifierSyntax.self)?
                            .specifier.trimmedDescription == "inout"
                    } ?? false
            }

        guard !containsInout else {
            throw ExpansionError.inoutNotSupportedYet
        }

        let awaitKeyword: TokenSyntax = function.isAsync ? "await " : ""
        let tryKeyword: TokenSyntax = function.isThrowing ? "try " : ""

        function.body = try .init {
            let name: TokenSyntax = "\(function.name)_genericOpen"
            let effectSpecifier: TokenSyntax =
                if let specifier = function.signature.effectSpecifiers?.trimmed {
                    "\(specifier) "
                } else {
                    ""
                }
            let setter: TokenSyntax = if function.isMutating {
                "set { self.base = newValue }"
            } else {
                ""
            }
            if let staticBase {
                "\(tryKeyword)\(awaitKeyword)__implicitCast(\(staticBase).\(function.name)(\(raw: formattedParameters)))"
            } else if let staticImpl = try getStaticImplType(of: function, node: node) {
                switch staticImpl {
                case let .value(tokenSyntax):
                    "\(tokenSyntax)"

                case let .type(tokenSyntax):
                    "\(tryKeyword)\(awaitKeyword)__implicitCast(\(tokenSyntax).\(function.name)(\(raw: formattedParameters)))"

                case let .direct(tokenSyntax, _):
                    "\(tryKeyword)\(awaitKeyword)__implicitCast(\(tokenSyntax)(\(raw: formattedParametersPure)))"

                case .fatalError:
                    staticInaccessibleFatalError
                }
            } else {
                if function.isThrowing {
                    """
                    func \(name)<T: \(protocolName)>(_: T) \(effectSpecifier)-> \(function.returnType) {
                        var base: T {
                            get { self.base as! T }
                            \(setter)
                        };
                        do {
                            return try \(awaitKeyword)base.\(function.name)(\(raw: formattedParameters))
                        } catch let error {
                            throw __implicitCast(error)
                        }
                    };
                    """
                    "return try \(awaitKeyword)__implicitCast(_openExistential(self.base, do: \(name)))"
                } else {
                    """
                    func \(name)<T: \(protocolName)>(_: T) \(effectSpecifier)-> \(function.returnType) {
                        var base: T {
                            get { self.base as! T }
                            \(setter)
                        };
                        return \(awaitKeyword)base.\(function.name)(\(raw: formattedParameters))
                    };
                    """
                    "return \(awaitKeyword)__implicitCast(_openExistential(self.base, do: \(name)))"
                }
            }
        }
    }

    static func addImplementationToVariable(
        _ variable: inout VariableDeclSyntax,
        node: AttributeSyntax,
        protocolName: TokenSyntax,
        staticBase: TokenSyntax? = nil
    ) throws {
        var binding: PatternBindingSyntax {
            get { variable.bindings[variable.bindings.startIndex] }
            set { variable.bindings[variable.bindings.startIndex] = newValue }
        }

        guard case var .accessors(accessors) = binding.accessorBlock?.accessors else {
            throw ExpansionError.compilerError("No accessors found")
        }

        try transform(&accessors) { _, accessor in
            let name = binding.pattern
                .as(IdentifierPatternSyntax.self)!
                .identifier

            let awaitKeyword: TokenSyntax = accessor.isAsync ? "await " : ""
            let tryKeyword: TokenSyntax = accessor.isThrowing ? "try " : ""

            if let staticImpl = try getStaticImplType(of: variable, node: node) {
                switch accessor.accessorSpecifier.trimmedDescription {
                case "get":
                    accessor.body = .init {
                        switch staticImpl {
                        case let .value(tokenSyntax):
                            "__implicitCast(\(tokenSyntax))"

                        case let .type(tokenSyntax):
                            "__implicitCast(\(tokenSyntax).\(name))"

                        case let .direct(tokenSyntax, _):
                            "\(tryKeyword)\(awaitKeyword)__implicitCast(\(tokenSyntax)())"

                        case .fatalError:
                            staticInaccessibleFatalError
                        }
                    }
                case "set":
                    accessor.body = .init {
                        switch staticImpl {
                        case let .type(tokenSyntax):
                            "\(tokenSyntax).\(name) = __implicitCast(newValue)"

                        case let .direct(_, tokenSyntax?):
                            "\(tryKeyword)\(awaitKeyword)\(tokenSyntax)(newValue)"

                        case .direct, .value, .fatalError:
                            staticInaccessibleFatalError
                        }
                    }
                default:
                    throw ExpansionError
                        .notSupportedAccessor(accessor.accessorSpecifier.text)
                }

                return
            }

            switch accessor.accessorSpecifier.trimmedDescription {
            case "get":
                let effectSpecifier: TokenSyntax =
                    if let specifier = accessor.effectSpecifiers?.trimmed {
                        "\(specifier) "
                    } else {
                        ""
                    }
                let type: TypeSyntax = binding.typeAnnotation!.type
                let setter: TokenSyntax = if accessor.isMutating {
                    "set { self.base = newValue }"
                } else {
                    ""
                }

                accessor.body = .init {
                    if let staticBase {
                        "\(tryKeyword)\(awaitKeyword)__implicitCast(\(staticBase).\(name))"
                    } else {
                        if accessor.isThrowing {
                            """
                            func \(name)_genericOpen<T: \(protocolName)>(_: T) \(effectSpecifier)-> \(type) {
                                var base: T {
                                    get { self.base as! T }
                                    \(setter)
                                };
                                do {
                                    return try \(awaitKeyword)base.\(name)
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            """
                            "return try \(awaitKeyword)__implicitCast(_openExistential(self.base, do: \(name)_genericOpen))"
                        } else {
                            """
                            func \(name)_genericOpen<T: \(protocolName)>(_: T) \(effectSpecifier)-> \(type) {
                                var base: T {
                                    get { self.base as! T }
                                    \(setter)
                                };
                                return \(awaitKeyword)base.\(name)
                            };
                            """
                            "return \(awaitKeyword)__implicitCast(_openExistential(self.base, do: \(name)_genericOpen))"
                        }
                    }
                }

            case "set":
                accessor.body = .init {
                    if let staticBase {
                        "\(tryKeyword)\(awaitKeyword)\(staticBase).\(name) = __implicitCast(newValue)"
                    } else {
                        """
                        func \(name)_genericOpen<T: \(protocolName)>(_: T) {
                            var base: T {
                                get { self.base as! T }
                                set { self.base = newValue }
                            };
                            base.\(name) = __implicitCast(newValue)
                        };
                        """
                        "_openExistential(self.base, do: \(name)_genericOpen)"
                    }
                }

            default:
                throw ExpansionError
                    .notSupportedAccessor(accessor.accessorSpecifier.text)
            }
        }

        binding.accessorBlock?.accessors = .accessors(accessors)
    }

    static func addImplementationToSubscript(
        _ subscript: inout SubscriptDeclSyntax,
        node: AttributeSyntax,
        protocolName: TokenSyntax,
        staticBase: TokenSyntax? = nil
    ) throws {
        var parameters: FunctionParameterListSyntax {
            get { `subscript`.parameterClause.parameters }
            set { `subscript`.parameterClause.parameters = newValue }
        }

        guard case var .accessors(accessors) = `subscript`.accessorBlock?.accessors else {
            throw ExpansionError.compilerError("No accessors found")
        }

        let labels = `subscript`.parameterLabels
        let inputs = `subscript`.getParameterInputsAndFillEmpty()

        let containsInout = `subscript`.parameterClause.parameters
            .contains {
                $0.type.as(AttributedTypeSyntax.self)?
                    .specifiers
                    .contains {
                        $0.as(SimpleTypeSpecifierSyntax.self)?
                            .specifier.trimmedDescription == "inout"
                    } ?? false
            }

        guard !containsInout else {
            throw ExpansionError.inoutNotSupportedYet
        }

        let formattedParameters = zip(labels, inputs)
            .map { label, input in
                guard let label else {
                    return "__implicitCast(\(input))"
                }

                return "\(label): __implicitCast(\(input))"
            }
            .joined(separator: ", ")

        let formattedParametersPure = zip(labels, inputs)
            .map { label, input in
                guard let label else {
                    return "\(input)"
                }

                return "\(label): \(input)"
            }
            .joined(separator: ", ")

        try transform(&accessors) { _, accessor in
            let awaitKeyword: TokenSyntax = accessor.isAsync ? "await " : ""
            let tryKeyword: TokenSyntax = accessor.isThrowing ? "try " : ""

            if let staticImpl = try getStaticImplType(of: `subscript`, node: node) {
                switch accessor.accessorSpecifier.trimmedDescription {
                case "get":
                    accessor.body = .init {
                        switch staticImpl {
                        case let .value(tokenSyntax):
                            "__implicitCast(\(tokenSyntax))"

                        case let .type(tokenSyntax):
                            "\(tryKeyword)\(awaitKeyword)__implicitCast(\(tokenSyntax)[\(raw: formattedParameters)])"

                        case let .direct(tokenSyntax, _):
                            "\(tryKeyword)\(awaitKeyword)__implicitCast(\(tokenSyntax)(\(raw: formattedParametersPure)))"

                        case .fatalError:
                            staticInaccessibleFatalError
                        }
                    }
                case "set":
                    accessor.body = .init {
                        switch staticImpl {
                        case let .type(tokenSyntax):
                            "\(tokenSyntax)[\(raw: formattedParameters)] = __implicitCast(newValue)"

                        case let .direct(_, tokenSyntax?):
                            "\(tryKeyword)\(awaitKeyword)__implicitCast(\(tokenSyntax)(newValue, \(raw: formattedParametersPure)))"

                        case .value, .fatalError, .direct:
                            staticInaccessibleFatalError
                        }
                    }
                default:
                    throw ExpansionError
                        .notSupportedAccessor(accessor.accessorSpecifier.text)
                }
                return
            }

            switch accessor.accessorSpecifier.trimmedDescription {
            case "get":
                accessor.body = .init {
                    let effectSpecifier: TokenSyntax =
                        if let specifier = accessor.effectSpecifiers?.trimmed {
                            "\(specifier) "
                        } else {
                            ""
                        }
                    let setter: TokenSyntax = if accessor.isMutating {
                        "set { self.base = newValue }"
                    } else {
                        ""
                    }

                    if let staticBase {
                        "\(tryKeyword)\(awaitKeyword)\(staticBase)[\(raw: formattedParameters)]"
                    } else {
                        if `subscript`.isThrowing {
                            """
                            func subscript_genericOpen<T: \(protocolName)>(_: T) \(effectSpecifier)-> \(`subscript`.returnType) {
                                var base: T {
                                    get { self.base as! T }
                                    \(setter)
                                };
                                do {
                                    return try \(awaitKeyword)base[\(raw: formattedParameters)]
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            """
                            "return try \(awaitKeyword)__implicitCast(_openExistential(self.base, do: subscript_genericOpen))"
                        } else {
                            """
                            func subscript_genericOpen<T: \(protocolName)>(_: T) \(effectSpecifier)-> \(`subscript`.returnType) {
                                var base: T {
                                    get { self.base as! T }
                                    \(setter)
                                };
                                return \(awaitKeyword)base[\(raw: formattedParameters)]
                            };
                            """
                            "return \(awaitKeyword)__implicitCast(_openExistential(self.base, do: subscript_genericOpen))"
                        }
                    }
                }
            case "set":
                accessor.body = .init {
                    if let staticBase {
                        "\(tryKeyword)\(awaitKeyword)\(staticBase)[\(raw: formattedParameters)] = newValue"
                    } else {
                        let setter: TokenSyntax = if accessor.isMutating {
                            "set { self.base = newValue }"
                        } else {
                            ""
                        }

                        """
                        func subscript_genericOpen<T: \(protocolName)>(_: T) {
                            var base: T {
                                get { self.base as! T }
                                \(setter)
                            };
                            return base[\(raw: formattedParameters)] = __implicitCast(newValue)
                        };
                        """
                        "_openExistential(self.base, do: subscript_genericOpen)"
                    }
                }
            default:
                throw ExpansionError
                    .notSupportedAccessor(accessor.accessorSpecifier.text)
            }
        }

        `subscript`.accessorBlock?.accessors = .accessors(accessors)
    }

    static func addImplementationToInit(
        _ initializer: inout InitializerDeclSyntax,
        node: AttributeSyntax,
        protocolName _: TokenSyntax
    ) throws {
        var parameters: FunctionParameterListSyntax {
            get { initializer.signature.parameterClause.parameters }
            set { initializer.signature.parameterClause.parameters = newValue }
        }

        let labels = initializer.parameterLabels
        let inputs = initializer.getParameterInputsAndFillEmpty()

        let formattedParameters = zip(labels, inputs)
            .map { label, input in
                guard let label else {
                    return "__implicitCast(\(input))"
                }

                return "\(label): __implicitCast(\(input))"
            }
            .joined(separator: ", ")

        let formattedParametersPure = zip(labels, inputs)
            .map { label, input in
                guard let label else {
                    return "\(input)"
                }

                return "\(label): \(input)"
            }
            .joined(separator: ", ")

        let awaitKeyword: TokenSyntax = initializer.isAsync ? "await " : ""
        let tryKeyword: TokenSyntax = initializer.isThrowing ? "try " : ""

        initializer.body = try .init {
            if let staticImpl = try getStaticImplType(of: initializer, node: node) {
                switch staticImpl {
                case let .value(tokenSyntax):
                    "self = \(tryKeyword)\(awaitKeyword)__implicitCast(\(tokenSyntax))"

                case let .type(tokenSyntax):
                    "\(tryKeyword)\(awaitKeyword)self.init(\(tokenSyntax)(\(raw: formattedParameters)))"

                case let .direct(tokenSyntax, _):
                    if initializer.isOptional {
                        """
                        if let value: Self = \(tryKeyword)\(awaitKeyword)\(tokenSyntax)(\(raw: formattedParametersPure)) {
                            self = __implicitCast(value)
                        } else {
                            return nil
                        }
                        """
                    } else {
                        "self = __implicitCast(\(tryKeyword)\(awaitKeyword)\(tokenSyntax)(\(raw: formattedParametersPure)))"
                    }

                case .fatalError:
                    staticInaccessibleFatalError
                }
            }
        }
    }

    static func getStaticImplType(
        of syntax: some WithAttributesSyntax & WithModifiersSyntax,
        node: AttributeSyntax
    ) throws -> StaticImplType? {
        guard syntax.isStatic else {
            return nil
        }

        let attributes = try syntax.attributes.compactMap { attribute in
            guard
                let attribute = attribute.as(AttributeSyntax.self),
                let name = attribute.attributeName.as(IdentifierTypeSyntax.self)
            else {
                return StaticImplType.fatalError
            }

            switch name.name.trimmedDescription {
            case "DefaultType":
                guard
                    let genericName = name.genericArgumentClause?
                    .arguments.first?
                    .argument.as(IdentifierTypeSyntax.self)?.name
                else {
                    throw ExpansionError.compilerError("No generic found")
                }
                return StaticImplType.type(genericName)

            case "DefaultValue":
                guard
                    let inputValue = attribute.arguments?
                    .as(LabeledExprListSyntax.self)?.first?.expression
                else {
                    throw ExpansionError.compilerError("No value found")
                }

                return StaticImplType.value("\(inputValue)")

            case "DefaultExternal":
                guard
                    let arguments = attribute.arguments?
                    .as(LabeledExprListSyntax.self),
                    let firstExpr = arguments.first?.expression
                else {
                    throw ExpansionError.compilerError("No value found")
                }

                let first = firstExpr
                    .as(StringLiteralExprSyntax.self)?
                    .segments.first!
                    .as(StringSegmentSyntax.self)?
                    .content ?? TokenSyntax("\(firstExpr)")

                if arguments.count == 2 {
                    let secondExpr = arguments[arguments.index(at: 1)].expression
                    let second = secondExpr
                        .as(StringLiteralExprSyntax.self)?
                        .segments.first!
                        .as(StringSegmentSyntax.self)?
                        .content ?? TokenSyntax("\(secondExpr)")

                    return StaticImplType.direct("\(first)", "\(second)")
                }

                return StaticImplType.direct("\(first)")

            case "DefaultNone":
                return StaticImplType.fatalError

            default:
                return nil
            }
        }

        guard let specifier = attributes.first else {
            throw DiagnosticsError(diagnostics: [
                ExpansionDiagnostic.noStaticsAllowed(node: node),
            ])
        }

        return specifier
    }
}

extension TypeEraserMacro: MemberMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let options = try getOptions(node: node)

        guard options.contains(.exportStaticRequirements) else {
            return []
        }

        let members = declaration.memberBlock.members
            .map(\.decl)
            .compactMap(checkStaticAndReturnNonStatic)
            .compactMap(trimDefaultMacros)

        return members
    }

    static func checkStaticAndReturnNonStatic(
        _ syntax: DeclSyntax
    ) -> DeclSyntax? {
        if syntax.is(InitializerDeclSyntax.self) {
            return nil
        }

        guard
            var syntax = syntax.asProtocol((any WithModifiersSyntax).self),
            syntax.isStatic
        else { return nil }

        syntax.modifiers = syntax.modifiers.filter { syntax in
            syntax.name.trimmedDescription != "static"
        }

        return DeclSyntax(syntax)
    }

    static func trimDefaultMacros(_ syntax: DeclSyntax) -> DeclSyntax? {
        guard
            var syntax = syntax.asProtocol((any WithAttributesSyntax).self)
        else {
            return nil
        }

        syntax.attributes = syntax.attributes.filter { attribute in
            let name = attribute
                .as(AttributeSyntax.self)!
                .attributeName
                .as(IdentifierTypeSyntax.self)!
                .name.text

            return !defaultMacroNames.contains(name)
        }

        return DeclSyntax(syntax)
    }
}

extension TypeEraserMacro: ExtensionMacro {
    static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let options = try getOptions(node: node)

        guard options.contains(.exportStaticRequirements) else {
            return []
        }

        let `protocol` = try getRawProtocol(from: declaration, node: node)

        var members = declaration.memberBlock.members
            .map(\.decl)
            .compactMap(checkStaticAndReturnNonStatic)
            .compactMap(trimDefaultMacros)

        try transform(&members) { _, decl in
            switch decl.kind {
            case .functionDecl:
                var function: FunctionDeclSyntax {
                    get { decl.cast(FunctionDeclSyntax.self) }
                    set { decl = DeclSyntax(newValue) }
                }

                try addImplementationToFunction(
                    &function,
                    node: node,
                    protocolName: `protocol`.name.trimmed,
                    staticBase: "Self"
                )

            case .variableDecl:
                var variable: VariableDeclSyntax {
                    get { decl.cast(VariableDeclSyntax.self) }
                    set { decl = DeclSyntax(newValue) }
                }

                try addImplementationToVariable(
                    &variable,
                    node: node,
                    protocolName: `protocol`.name.trimmed,
                    staticBase: "Self"
                )

            case .subscriptDecl:
                var `subscript`: SubscriptDeclSyntax {
                    get { decl.cast(SubscriptDeclSyntax.self) }
                    set { decl = DeclSyntax(newValue) }
                }

                try addImplementationToSubscript(
                    &`subscript`,
                    node: node,
                    protocolName: `protocol`.name.trimmed,
                    staticBase: "Self"
                )

            case .initializerDecl:
                var initializer: InitializerDeclSyntax {
                    get { decl.cast(InitializerDeclSyntax.self) }
                    set { decl = DeclSyntax(newValue) }
                }

                try addImplementationToInit(
                    &initializer,
                    node: node,
                    protocolName: `protocol`.name.trimmed
                )

            case .typeAliasDecl: break
            case .associatedTypeDecl: break

            default:
                throw ExpansionError.notSupportedDecl(kind: decl.kind)
            }
        }

        if members.isEmpty { return [] }

        return try [
            ExtensionDeclSyntax("extension \(type)") { members },
        ]
    }
}

let staticInaccessibleFatalError: ExprSyntax = #"""
fatalError("Tried to access static member \(#function) from type eraser")
"""#

enum StaticImplType {
    case value(TokenSyntax)
    case type(TokenSyntax)
    case direct(TokenSyntax, TokenSyntax? = nil)
    case fatalError
}

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
