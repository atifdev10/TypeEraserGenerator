import SwiftSyntaxMacros
import SwiftSyntax
import SwiftDiagnostics
import MultiModule
import Foundation

extension TypeEraserMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let `protocol` = try getRawProtocol(from: declaration, node: node)
        var `struct` = convertProtocolToTypeEraserStruct(`protocol`)

        let protocolName: TokenSyntax =
        "\(raw: `protocol`.name.trimmedDescription)"

        `struct`.name = "Any\(raw: `struct`.name.trimmedDescription)"
        `struct`.genericParameterClause = nil

        var members: MemberBlockItemListSyntax {
            get { `struct`.memberBlock.members }
            set { `struct`.memberBlock.members = newValue }
        }

        var associates = try removeAssociates(&members, node: node)

        let globalOptions = try getOptionsFromTypeEraser(node: node)

        var pendingDeletionIndexes = [SyntaxChildrenIndex]()

        try transform(&members, access: \.decl) { index, decl in
            switch decl.kind {
            case .functionDecl:
                try withDeclSyntaxCast(
                    &decl, to: FunctionDeclSyntax.self
                ) { function in
                    let implType = try getStaticImplementationType(of: function, node: node)

                    if case .external = implType {
                        pendingDeletionIndexes.append(index)
                        throw LoopWorkflow.continue
                    }

                    try addImplementationToFunction(
                        &function,
                        node: node,
                        protocolName: protocolName,
                        options: globalOptions
                    )
                }

            case .variableDecl:
                try withDeclSyntaxCast(
                    &decl, to: VariableDeclSyntax.self
                ) { variable in
                    let implType = try getStaticImplementationType(of: variable, node: node)

                    if case .external = implType {
                        pendingDeletionIndexes.append(index)
                        throw LoopWorkflow.continue
                    }

                    try addImplementationToVariable(
                        &variable,
                        node: node,
                        protocolName: protocolName,
                        options: globalOptions
                    )
                }

            case .subscriptDecl:
                try withDeclSyntaxCast(
                    &decl, to: SubscriptDeclSyntax.self
                ) { `subscript` in
                    let implType = try getStaticImplementationType(of: `subscript`, node: node)

                    if case .external = implType {
                        pendingDeletionIndexes.append(index)
                        throw LoopWorkflow.continue
                    }

                    try addImplementationToSubscript(
                        &`subscript`,
                        node: node,
                        protocolName: protocolName,
                        options: globalOptions
                    )
                }

            case .initializerDecl:
                try withDeclSyntaxCast(
                    &decl, to: InitializerDeclSyntax.self
                ) { initializer in
                    let implType = try getStaticImplementationType(of: initializer, node: node)

                    if case .external = implType {
                        pendingDeletionIndexes.append(index)
                        throw LoopWorkflow.continue
                    }

                    try addImplementationToInit(
                        &initializer,
                        node: node,
                        protocolName: protocolName,
                        options: globalOptions
                    )
                }

            case .associatedTypeDecl, .typeAliasDecl: break

            default:
                throw ExpansionError.notSupportedDecl(kind: decl.kind)
            }

            decl = decl.trimmed

            removeHelperMacros(&decl)
        }

        members.remove(bulk: pendingDeletionIndexes)

        // TODO: Add type checking for defaults

        let boilerplateDecls: [DeclSyntax] = [
            """
            /// The value wrapped by this instance.
            var base: any \(protocolName)
            """,
            """
            /// Create an instance that type-erases `\(`protocol`.name.trimmed)`.
            init(_ erasing: some \(protocolName)) {
                self.base = erasing
            }
            """,
            """
            /// Create an instance that type-erases `\(`protocol`.name.trimmed)`.
            init(erasing: any \(protocolName)) {
                self.base = erasing
            }
            """,
        ]

        let items = boilerplateDecls.map { MemberBlockItemSyntax(decl: $0) }

        members.insert(contentsOf: items, at: members.startIndex)

        let inheritances = InheritedTypeListSyntax {
            Array(`protocol`.inheritanceClause?.inheritedTypes ?? [])
        }

        for inheritance in inheritances {
            if let type = IdentifierTypeSyntax(inheritance.type) {
                try addConformanceRequirements(
                    type,
                    protocol: `protocol`,
                    members: &members,
                    associates: &associates
                )
            }

            if let type = MemberTypeSyntax(inheritance.type) {
                try addConformanceRequirements(
                    type,
                    protocol: `protocol`,
                    members: &members,
                    associates: &associates
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

    private static func convertProtocolToTypeEraserStruct(
        _ prot: ProtocolDeclSyntax
    ) -> StructDeclSyntax {
        var toBeStruct = prot

        let protocolKeyword = prot.protocolKeyword
        let leadingTrivia = protocolKeyword.leadingTrivia
        let trailingTrivia = protocolKeyword.trailingTrivia

        toBeStruct.protocolKeyword = "struct"
        toBeStruct.protocolKeyword.leadingTrivia = leadingTrivia
        toBeStruct.protocolKeyword.trailingTrivia = trailingTrivia

        let decl: DeclSyntax = "\(raw: toBeStruct)"

        let conformance = InheritanceClauseSyntax {
            InheritedTypeSyntax(
                type: "\(raw: prot.name.trimmedDescription)" as TypeSyntax
            )
            InheritedTypeSyntax(type: "TypeEraser" as TypeSyntax)
        }

        return decl.cast(StructDeclSyntax.self)
            .with(\.inheritanceClause, conformance)
    }

    private static func addConformanceRequirements(
        _ inheritance: some WithGenericArgumentsTypeSyntax & WithNameTypeSyntax,
        protocol: ProtocolDeclSyntax,
        members: inout MemberBlockItemListSyntax,
        associates: inout [String: String]
    ) throws {
        switch inheritance.name.trimmedDescription {
        case "Identifiable":
            let value: String? = run {
                if let associated = associates["ID"] {
                    return associated
                }

                if let generic = inheritance.genericArgumentClause?.arguments.first?.argument {
                    return generic.trimmedDescription
                }

                if let clause = `protocol`.genericWhereClause?.requirements
                    .map(\.requirement)
                    .compactMap(SameTypeRequirementSyntax.init)
                    .first(where: {
                        $0.leftType.trimmedDescription == any(
                            of: "ID", "Self.ID"
                        )
                    }) {
                    return "\(clause.rightType)"
                }

                return members.compactMap { member -> String? in
                    guard
                        let variable = VariableDeclSyntax(member.decl),
                        let binding = variable.bindings.first,
                        IdentifierPatternSyntax(binding.pattern)?
                            .identifier.text == "id"
                    else {
                        return nil
                    }

                    return "\(binding.typeAnnotation!.type)"
                }.first
            }

            guard let value else {
                throw ExpansionError.associatedMustHaveErasureSpecifier(
                    associated: "ID"
                )
            }

            associates["ID"] = value

            let variableNames = members
                .map(\.decl)
                .compactMap(VariableDeclSyntax.init)
                .flatMap(\.bindings)
                .map(\.pattern)
                .compactMap(IdentifierPatternSyntax.init)
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

            fallthrough // Hashable is also Equatable

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

    private static func removeAssociates(
        _ members: inout MemberBlockItemListSyntax,
        node _: AttributeSyntax
    ) throws -> [String: String] {
        let associateDecls = members
            .remove { decl in
                decl.decl.is(AssociatedTypeDeclSyntax.self)
            }
            .map(\.decl)
            .compactMap(AssociatedTypeDeclSyntax.init)

        let associateTuples: [(String, String)] = try associateDecls
            .map { associated in
                var type: TokenSyntax?

                for attribute in associated.attributes {
                    guard
                        let attribute = AttributeSyntax(attribute),
                        let name = IdentifierTypeSyntax(attribute.attributeName),
                        attribute.name == "Erase"
                    else {
                        continue
                    }

                    if let generic = name.genericArgumentClause?.arguments.first {
                        type = "\(generic.argument)"
                        break
                    }

                    guard let inheritanceClause = associated.inheritanceClause else {
                        type = "Any"
                        break
                    }


                    let types = inheritanceClause.inheritedTypes
                        .map(\.type)

                    let empty = CompositionTypeSyntax(elements: [])

                    var totalComposition = types
                        .reduce(into: empty) { partialResult, result in
                            let composition = CompositionTypeElementSyntax(
                                type: result, ampersand: "&"
                            )

                            partialResult.elements.append(composition)
                        }

                    totalComposition.elements[
                        totalComposition.elements.index(
                            before: totalComposition.elements.endIndex
                        )
                    ].ampersand = nil

                    type = "(\(totalComposition))._Eraser_"
                    break
                }

                guard let type else {
                    throw ExpansionError.associatedMustHaveErasureSpecifier(
                        associated: associated.name.trimmedDescription
                    )
                }

                return (
                    associated.name.trimmedDescription,
                    type.trimmedDescription
                )
            }

        return Dictionary(uniqueKeysWithValues: associateTuples)
    }

    private static func getStaticImplementationType(
        of syntax: some WithAttributesSyntax & WithModifiersSyntax,
        node: AttributeSyntax
    ) throws -> StaticImplementationType? {
        guard syntax.isStatic else {
            return nil
        }

        guard
        let attribute = syntax.attributes
            .compactMap(AttributeSyntax.init)
            .first(where: { $0.name == "Default" })
        else {
            throw DiagnosticsError(diagnostics: [
                ExpansionDiagnostic.noStaticsAllowed(node: node)
            ])
        }

        guard let list = LabeledExprListSyntax(attribute.arguments),
              let argument = list.first else {
            throw ExpansionError.incorrectOptions
        }

        if let memberAccess = MemberAccessExprSyntax(argument.expression) {
            let type = memberAccess.declName

            guard memberAccess.base == any(of: nil, "DefaultBehavior") else {
                throw ExpansionError.incorrectOptions
            }

            switch type.baseName.text {
            case "external":
                return .external
            case "error":
                return .error
            default:
                return .error
            }
        }

        if let functionCall = FunctionCallExprSyntax(argument.expression) {
            guard let list = LabeledExprListSyntax(functionCall.arguments),
                  let argument = list.first else {
                throw ExpansionError.incorrectOptions
            }

            let type = functionCall.calledExpression

            if let memberAccess = MemberAccessExprSyntax(type) {
                let type = memberAccess.declName

                guard memberAccess.base == any(of: nil, "DefaultBehavior") else {
                    throw ExpansionError.incorrectOptions
                }

                switch type.baseName.text {
                case "value":
                    return .value("\(argument.expression)")
                case "type":
                    var type = argument.expression.trimmedDescription

                    type.removeLast(5)

                    return .type("\(raw: type)")
                default:
                    return .error
                }
            }
        }

        throw ExpansionError.incorrectOptions
    }
}

// MARK: - Function Implementation

private extension TypeEraserMacro {
    static func addImplementationToFunction(
        _ function: inout FunctionDeclSyntax,
        node: AttributeSyntax,
        protocolName: TokenSyntax,
        options globalOptions: TypeEraserOptions
    ) throws {
        function.fillEmptyInputParametersIfNeeded()

        let formattedParameters = function.formattedParameters {
            "__implicitCast(\($0))"
        }

        let formattedParametersNotCasted = function.formattedParameters()

        guard !function.containsInoutParameter else {
            throw ExpansionError.inoutNotSupportedYet
        }

        let awaitKeyword: TokenSyntax = function.isAsync ? "await " : ""
        let tryKeyword: TokenSyntax = function.isThrowing ? "try " : ""

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

        let localOptions = try getOptionsFromSomeDecl(decl: function)
        let options = globalOptions.union(localOptions)

        function.body = if let staticImplementation = try getStaticImplementationType(of: function, node: node) {
            switch staticImplementation {
            case let .value(tokenSyntax) where options
                    .contains(.assureNoAssociates):
                "{\(tokenSyntax)}"

            case let .value(tokenSyntax):
                "{__implicitCast(\(tokenSyntax))}"

            case let .type(tokenSyntax) where options
                    .contains(.assureNoAssociates):
                "{\(tryKeyword)\(awaitKeyword)\(tokenSyntax).\(function.name)(\(raw: formattedParametersNotCasted))}"

            case let .type(tokenSyntax):
                "{\(tryKeyword)\(awaitKeyword)__implicitCast(\(tokenSyntax).\(function.name)(\(raw: formattedParameters)))}"

            case .external, .error:
                "{\(staticInaccessibleFatalError)}"
            }
        } else {
            if options.contains(.assureNoAssociates) {
                "{\(tryKeyword)\(awaitKeyword)base.\(function.name)(\(raw: formattedParametersNotCasted))}"
            } else if function.isThrowing {
                """
                {\
                func \(name)<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(function.returnType) {\
                    var base: _OpenBase_ {\
                        get { self.base as! _OpenBase_ }\
                        \(setter)\
                    };\
                    do {\
                        return try \(awaitKeyword)base.\(function.name)(\(raw: formattedParameters))\
                    } catch let error {\
                        throw __implicitCast(error)\
                    }\
                };\
                return try \(awaitKeyword)__implicitCast(_openExistential(self.base, do: \(name)))\
                }
                """
            } else {
                """
                {\
                func \(name)<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(function.returnType) {\
                    var base: _OpenBase_ {\
                        get { self.base as! _OpenBase_ }\
                        \(setter)\
                    };\
                    return \(awaitKeyword)base.\(function.name)(\(raw: formattedParameters))\
                };\
                return \(awaitKeyword)__implicitCast(_openExistential(self.base, do: \(name)))\
                }
                """
            }
        }
    }
}

// MARK: - Variable Implementation

private extension TypeEraserMacro {
    static func addImplementationToVariable(
        _ variable: inout VariableDeclSyntax,
        node: AttributeSyntax,
        protocolName: TokenSyntax,
        options globalOptions: TypeEraserOptions
    ) throws {
        var binding: PatternBindingSyntax {
            get { variable.bindings[variable.bindings.startIndex] }
            set { variable.bindings[variable.bindings.startIndex] = newValue }
        }

        guard binding.accessorBlock != nil else {
            throw ExpansionError.compilerError("No accessor block found")
        }

        var accessorBlock: AccessorBlockSyntax {
            get { binding.accessorBlock! }
            set { binding.accessorBlock! = newValue }
        }

        guard case .accessors = accessorBlock.accessors else {
            throw ExpansionError.compilerError("No accessors found")
        }

        var accessors: AccessorDeclListSyntax {
            get {
                guard
                    case let .accessors(accessors) = accessorBlock.accessors
                else {
                    fatalError()
                }

                return accessors
            }
            set { accessorBlock.accessors = .accessors(newValue) }
        }

        let localOptions = try getOptionsFromSomeDecl(decl: variable)
        let options = globalOptions.union(localOptions)

        try transform(&accessors) { _, accessor in
            let name = IdentifierPatternSyntax(binding.pattern)!.identifier
            
            let awaitKeyword: TokenSyntax = accessor.isAsync ? "await " : ""
            let tryKeyword: TokenSyntax = accessor.isThrowing ? "try " : ""


            if let staticImplementation = try getStaticImplementationType(of: variable, node: node) {
                switch accessor.accessorSpecifier.trimmedDescription {
                case "get":
                    accessor.body = switch staticImplementation {
                    case let .value(tokenSyntax) where options
                            .contains(.assureNoAssociates):
                        "{\(tokenSyntax)}"

                    case let .value(tokenSyntax):
                        "{__implicitCast(\(tokenSyntax))}"
                        
                    case let .type(tokenSyntax) where options
                            .contains(.assureNoAssociates):
                        "{\(tokenSyntax).\(name)}"

                    case let .type(tokenSyntax):
                        "{__implicitCast(\(tokenSyntax).\(name))}"

                    case .external, .error:
                        "{\(staticInaccessibleFatalError)}"
                    }
                    
                case "set":
                    accessor.body = switch staticImplementation {
                    case let .type(tokenSyntax) where options
                            .contains(.assureNoAssociates):
                        "{\(tokenSyntax).\(name) = newValue}"

                    case let .type(tokenSyntax):
                        "{\(tokenSyntax).\(name) = __implicitCast(newValue)}"

                    case .external, .value, .error:
                        "{\(staticInaccessibleFatalError)}"
                    }
                    
                default:
                    throw ExpansionError.notSupportedAccessor(
                        accessor.accessorSpecifier.text
                    )
                }

                return
            }

            switch accessor.accessorSpecifier.trimmedDescription {
            case "get":
                let type: TypeSyntax = binding.typeAnnotation!.type

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

                accessor.body = if options.contains(.assureNoAssociates) {
                    "{\(tryKeyword)\(awaitKeyword)base.\(name)}"
                } else {
                    if accessor.isThrowing {
                        """
                        {\
                        func \(name)_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(type) {\
                            var base: _OpenBase_ {\
                                get { self.base as! _OpenBase_ }\
                                \(setter)\
                            };\
                            do {\
                                return try \(awaitKeyword)base.\(name)\
                            } catch let error {\
                                throw __implicitCast(error)\
                            }\
                        };\
                        return try \(awaitKeyword)__implicitCast(_openExistential(self.base, do: \(name)_genericOpen))\
                        }
                        """
                    } else {
                        """
                        {\
                        func \(name)_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(type) {\
                            var base: _OpenBase_ {\
                                get { self.base as! _OpenBase_ }\
                                \(setter)\
                            };\
                            return \(awaitKeyword)base.\(name)\
                        };\
                        return \(awaitKeyword)__implicitCast(_openExistential(self.base, do: \(name)_genericOpen))\
                        }
                        """
                    }
                }

            case "set":
                accessor.body = if options.contains(.assureNoAssociates) {
                    "{base.\(name) = newValue}"
                } else {
                    """
                    {\
                    func \(name)_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) {\
                        var base: _OpenBase_ {\
                            get { self.base as! _OpenBase_ }\
                            set { self.base = newValue }\
                        };\
                        base.\(name) = __implicitCast(newValue)\
                    };\
                    _openExistential(self.base, do: \(name)_genericOpen)\
                    }
                    """
                }

            default:
                throw ExpansionError.notSupportedAccessor(
                    accessor.accessorSpecifier.text
                )
            }
        }
    }
}

// MARK: - Subscript Implementation

private extension TypeEraserMacro {
    static func addImplementationToSubscript(
        _ subscript: inout SubscriptDeclSyntax,
        node: AttributeSyntax,
        protocolName: TokenSyntax,
        options globalOptions: TypeEraserOptions
    ) throws {
        guard `subscript`.accessorBlock != nil else {
            throw ExpansionError.compilerError("No accessor block found")
        }

        var accessorBlock: AccessorBlockSyntax {
            get { `subscript`.accessorBlock! }
            set { `subscript`.accessorBlock! = newValue }
        }

        guard case .accessors = accessorBlock.accessors else {
            throw ExpansionError.compilerError("No accessors found")
        }

        var accessors: AccessorDeclListSyntax {
            get {
                guard
                    case let .accessors(accessors) = accessorBlock.accessors
                else {
                    fatalError()
                }

                return accessors
            }
            set { accessorBlock.accessors = .accessors(newValue) }
        }

        `subscript`.fillEmptyInputParametersIfNeeded()

        guard !`subscript`.containsInoutParameter else {
            throw ExpansionError.inoutNotSupportedYet
        }

        let formattedParameters = `subscript`.formattedParameters {
            "__implicitCast(\($0))"
        }

        let formattedParametersNotCasted = `subscript`.formattedParameters()

        let localOptions = try getOptionsFromSomeDecl(decl: `subscript`)
        let options = globalOptions.union(localOptions)

        try transform(&accessors) { _, accessor in
            let awaitKeyword: TokenSyntax = accessor.isAsync ? "await " : ""
            let tryKeyword: TokenSyntax = accessor.isThrowing ? "try " : ""

            if let staticImplementation = try getStaticImplementationType(of: `subscript`, node: node) {
                switch accessor.accessorSpecifier.trimmedDescription {
                case "get":
                    accessor.body = switch staticImplementation {
                    case let .value(tokenSyntax) where options
                            .contains(.assureNoAssociates):
                        "{\(tokenSyntax)}"

                    case let .value(tokenSyntax):
                        "{__implicitCast(\(tokenSyntax))}"

                    case let .type(tokenSyntax) where options
                            .contains(.assureNoAssociates):
                        "{\(tryKeyword)\(awaitKeyword)\(tokenSyntax)[\(raw: formattedParametersNotCasted)]}"

                    case let .type(tokenSyntax):
                        "{\(tryKeyword)\(awaitKeyword)__implicitCast(\(tokenSyntax)[\(raw: formattedParameters)])}"

                    case .external, .error:
                        "{\(staticInaccessibleFatalError)}"
                    }
                case "set":
                    accessor.body = switch staticImplementation {
                    case let .type(tokenSyntax):
                        "{\(tokenSyntax)[\(raw: formattedParameters)] = __implicitCast(newValue)}"

                    case .external, .value, .error:
                        "{\(staticInaccessibleFatalError)}"
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
                let setter: TokenSyntax = if accessor.isMutating {
                    "set { self.base = newValue }"
                } else {
                    ""
                }

                accessor.body = if options.contains(.assureNoAssociates) {
                    "{\(tryKeyword)\(awaitKeyword)base[\(raw: formattedParametersNotCasted)]}"
                } else if `subscript`.isThrowing {
                    """
                    {\
                    func subscript_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(`subscript`.returnType) {\
                        var base: _OpenBase_ {\
                            get { self.base as! _OpenBase_ }\
                            \(setter)\
                        };\
                        do {\
                            return try \(awaitKeyword)base[\(raw: formattedParameters)]\
                        } catch let error {\
                            throw __implicitCast(error)\
                        }\
                    };\
                    return try \(awaitKeyword)__implicitCast(_openExistential(self.base, do: subscript_genericOpen))\
                    }
                    """
                } else {
                    """
                    {\
                    func subscript_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(`subscript`.returnType) {\
                        var base: _OpenBase_ {\
                            get { self.base as! _OpenBase_ }\
                            \(setter)\
                        };\
                        return \(awaitKeyword)base[\(raw: formattedParameters)]\
                    };\
                    return \(awaitKeyword)__implicitCast(_openExistential(self.base, do: subscript_genericOpen))\
                    }
                    """
                }
            case "set":
                let setter: TokenSyntax = if accessor.isMutating {
                    "set { self.base = newValue }"
                } else {
                    ""
                }

                accessor.body = if options.contains(.assureNoAssociates) {
                    "{base[\(raw: formattedParametersNotCasted)] = newValue}"
                } else {
                    """
                    {\
                    func subscript_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) {\
                        var base: _OpenBase_ {\
                            get { self.base as! _OpenBase_ }\
                            \(setter)\
                        };\
                        return base[\(raw: formattedParameters)] = __implicitCast(newValue)\
                    };\
                    _openExistential(self.base, do: subscript_genericOpen)\
                    }
                    """
                }
            default:
                throw ExpansionError.notSupportedAccessor(
                    accessor.accessorSpecifier.text
                )
            }
        }
    }
}

// MARK: - Init Implementation

private extension TypeEraserMacro {
    static func addImplementationToInit(
        _ initializer: inout InitializerDeclSyntax,
        node: AttributeSyntax,
        protocolName _: TokenSyntax,
        options globalOptions: TypeEraserOptions
    ) throws {
        initializer.fillEmptyInputParametersIfNeeded()

        let formattedParameters = initializer.formattedParameters {
            "__implicitCast(\($0))"
        }

        let formattedParametersNotCasted = initializer.formattedParameters()

        guard !initializer.containsInoutParameter else {
            throw ExpansionError.inoutNotSupportedYet
        }

        let awaitKeyword: TokenSyntax = initializer.isAsync ? "await " : ""
        let tryKeyword: TokenSyntax = initializer.isThrowing ? "try " : ""

        let localOptions = try getOptionsFromSomeDecl(decl: initializer)
        let options = globalOptions.union(localOptions)

        initializer.body = if let staticImplementation = try getStaticImplementationType(of: initializer, node: node) {
            if initializer.isOptional {
                switch staticImplementation {
                case let .value(tokenSyntax) where options
                        .contains(.assureNoAssociates):
                    "{self = \(tokenSyntax)}"

                case let .value(tokenSyntax):
                    "{self = __implicitCast(\(tokenSyntax))}"

                case let .type(tokenSyntax) where options
                        .contains(.assureNoAssociates):
                    """
                    {\
                    guard let type = \(tryKeyword)\(awaitKeyword)\(tokenSyntax)(\(raw: formattedParametersNotCasted)) else {\
                        return nil\
                    };\
                    \(tryKeyword)\(awaitKeyword)self.init(type)\
                    }
                    """

                case let .type(tokenSyntax):
                    """
                    {\
                    guard let type = \(tryKeyword)\(awaitKeyword)\(tokenSyntax)(\(raw: formattedParameters)) else {\
                        return nil\
                    };\
                    \(tryKeyword)\(awaitKeyword)self.init(type)\
                    }
                    """

                case .external, .error:
                    "{\(staticInaccessibleFatalError)}"
                }
            } else {
                switch staticImplementation {
                case let .value(tokenSyntax) where options
                        .contains(.assureNoAssociates):
                    "{self = \(tokenSyntax)}"

                case let .value(tokenSyntax):
                    "{self = __implicitCast(\(tokenSyntax))}"

                case let .type(tokenSyntax) where options
                        .contains(.assureNoAssociates):
                    "{\(tryKeyword)\(awaitKeyword)self.init(\(tokenSyntax)(\(raw: formattedParametersNotCasted)))}"

                case let .type(tokenSyntax):
                    "{\(tryKeyword)\(awaitKeyword)self.init(\(tokenSyntax)(\(raw: formattedParameters)))}"

                case .external, .error:
                    "{\(staticInaccessibleFatalError)}"
                }
            }
        } else {
            "{}"
        }
    }
}
