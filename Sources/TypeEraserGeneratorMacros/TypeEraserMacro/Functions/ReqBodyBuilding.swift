import MultiModule
import SwiftDiagnostics
import SwiftSyntax

private enum StaticImplementationType {
    case value(TokenSyntax)
    case type(TokenSyntax)
    case external
    case error
}

private let staticInaccessiblePreconditionError: ExprSyntax = #"""
preconditionFailure("Tried to access static member \(#function) from type eraser")
"""#

private struct UnsupportedAccessorError: MacroErrorProtocol {
    let accessor: String

    init(_ accessor: String) {
        self.accessor = accessor
    }

    var description: String {
        "Accessor of type '\(accessor)' is currently unsupported"
    }
}

private struct InoutUnsupportedError: MacroErrorProtocol {
    var description: String {
        "Inout parameters are not supported yet"
    }
}

func buildRequirementsBodies(
    for members: inout MemberBlockItemListSyntax,
    baseName: TokenSyntax = "base",
    protocolName: TypeSyntax,
    options globalOptions: TypeEraserOptions
) throws {
    var pendingDeletionIndexes = [SyntaxChildrenIndex]()

    try transform(&members, access: \.decl) { index, decl in
        switch decl.kind {
        case .functionDecl:
            try withDeclSyntaxCast(
                &decl, to: FunctionDeclSyntax.self
            ) { function in
                let implType = try getStaticImplementationType(of: function)

                if case .external = implType {
                    pendingDeletionIndexes.append(index)
                    throw LoopWorkflow.continue
                }

                try addImplementationToFunction(
                    &function,
                    baseName: baseName,
                    protocolName: protocolName,
                    options: globalOptions
                )
            }

        case .variableDecl:
            try withDeclSyntaxCast(
                &decl, to: VariableDeclSyntax.self
            ) { variable in
                let implType = try getStaticImplementationType(of: variable)

                if case .external = implType {
                    pendingDeletionIndexes.append(index)
                    throw LoopWorkflow.continue
                }

                try addImplementationToVariable(
                    &variable,
                    baseName: baseName,
                    protocolName: protocolName,
                    options: globalOptions
                )
            }

        case .subscriptDecl:
            try withDeclSyntaxCast(
                &decl, to: SubscriptDeclSyntax.self
            ) { `subscript` in
                let implType = try getStaticImplementationType(of: `subscript`)

                if case .external = implType {
                    pendingDeletionIndexes.append(index)
                    throw LoopWorkflow.continue
                }

                try addImplementationToSubscript(
                    &`subscript`,
                    baseName: baseName,
                    protocolName: protocolName,
                    options: globalOptions
                )
            }

        case .initializerDecl:
            try withDeclSyntaxCast(
                &decl, to: InitializerDeclSyntax.self
            ) { initializer in
                let implType = try getStaticImplementationType(of: initializer)

                if case .external = implType {
                    pendingDeletionIndexes.append(index)
                    throw LoopWorkflow.continue
                }

                try addImplementationToInit(
                    &initializer,
                    baseName: baseName,
                    protocolName: protocolName,
                    options: globalOptions
                )
            }

        case .associatedTypeDecl,
             .macroExpansionDecl:
            pendingDeletionIndexes.append(index)

        case .typeAliasDecl: break

        default:
            throw MacroError("Requirement of type '\(decl.kind)' is unsupported")
        }

        decl = decl.trimmed

        removeHelperMacros(&decl)
    }

    members.remove(bulk: pendingDeletionIndexes)
}

// MARK: - Function Implementation

private func addImplementationToFunction(
    _ function: inout FunctionDeclSyntax,
    baseName: TokenSyntax,
    protocolName: TypeSyntax,
    options globalOptions: TypeEraserOptions
) throws {
    function.fillEmptyInputParametersIfNeeded()

    let formattedParameters = function.formattedParameters {
        "implicitCast(\($0))"
    }

    let formattedParametersNotCasted = function.formattedParameters()

    guard !function.containsInoutParameter else {
        throw InoutUnsupportedError()
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
        "set { self.\(baseName) = newValue }"
    } else {
        ""
    }

    let localOptions = try getOptions(decl: function)
    let options = globalOptions.union(localOptions)

    function.body = if let staticImplementation = try getStaticImplementationType(of: function) {
        switch staticImplementation {
        case let .value(tokenSyntax) where options
            .contains(.assureNoAssociates):
            "{\(tokenSyntax)}"

        case let .value(tokenSyntax):
            "{implicitCast(\(tokenSyntax))}"

        case let .type(tokenSyntax) where options
            .contains(.assureNoAssociates):
            "{\(tryKeyword)\(awaitKeyword)\(tokenSyntax).\(function.name)(\(raw: formattedParametersNotCasted))}"

        case let .type(tokenSyntax):
            "{\(tryKeyword)\(awaitKeyword)implicitCast(\(tokenSyntax).\(function.name)(\(raw: formattedParameters)))}"

        case .external, .error:
            "{\(staticInaccessiblePreconditionError)}"
        }
    } else {
        if options.contains(.assureNoAssociates) {
            "{\(tryKeyword)\(awaitKeyword)\(baseName).\(function.name)(\(raw: formattedParametersNotCasted))}"
        } else if function.isThrowing {
            """
            {\
            func \(name)<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(function.returnType) {\
                var localBase: _OpenBase_ {\
                    get { self.\(baseName) as! _OpenBase_ }\
                    \(setter)\
                };\
                do {\
                    return try \(awaitKeyword)implicitCast(localBase.\(function.name)(\(raw: formattedParameters)))\
                } catch let error {\
                    throw implicitCast(error)\
                }\
            };\
            return try \(awaitKeyword)implicitCast(_openExistential(self.\(baseName), do: \(name)))\
            }
            """
        } else {
            """
            {\
            func \(name)<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(function.returnType) {\
                var localBase: _OpenBase_ {\
                    get { self.\(baseName) as! _OpenBase_ }\
                    \(setter)\
                };\
                return \(awaitKeyword)implicitCast(localBase.\(function.name)(\(raw: formattedParameters)))\
            };\
            return \(awaitKeyword)implicitCast(_openExistential(self.\(baseName), do: \(name)))\
            }
            """
        }
    }
}

// MARK: - Variable Implementation

private func addImplementationToVariable(
    _ variable: inout VariableDeclSyntax,
    baseName: TokenSyntax,
    protocolName: TypeSyntax,
    options globalOptions: TypeEraserOptions
) throws {
    var binding: PatternBindingSyntax {
        get { variable.bindings[variable.bindings.startIndex] }
        set { variable.bindings[variable.bindings.startIndex] = newValue }
    }

    guard binding.accessorBlock != nil else {
        throw CompilerError("No accessor block found")
    }

    var accessorBlock: AccessorBlockSyntax {
        get { binding.accessorBlock! }
        set { binding.accessorBlock! = newValue }
    }

    guard case .accessors = accessorBlock.accessors else {
        throw CompilerError("No accessors found")
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

    let localOptions = try getOptions(decl: variable)
    let options = globalOptions.union(localOptions)

    try transform(&accessors) { _, accessor in
        let name = IdentifierPatternSyntax(binding.pattern)!.identifier

        let awaitKeyword: TokenSyntax = accessor.isAsync ? "await " : ""
        let tryKeyword: TokenSyntax = accessor.isThrowing ? "try " : ""

        if let staticImplementation = try getStaticImplementationType(of: variable) {
            switch accessor.accessorSpecifier.trimmedDescription {
            case "get":
                accessor.body = switch staticImplementation {
                case let .value(tokenSyntax) where options
                    .contains(.assureNoAssociates):
                    "{\(tokenSyntax)}"

                case let .value(tokenSyntax):
                    "{implicitCast(\(tokenSyntax))}"

                case let .type(tokenSyntax) where options
                    .contains(.assureNoAssociates):
                    "{\(tokenSyntax).\(name)}"

                case let .type(tokenSyntax):
                    "{implicitCast(\(tokenSyntax).\(name))}"

                case .external, .error:
                    "{\(staticInaccessiblePreconditionError)}"
                }

            case "set":
                accessor.body = switch staticImplementation {
                case let .type(tokenSyntax) where options
                    .contains(.assureNoAssociates):
                    "{\(tokenSyntax).\(name) = newValue}"

                case let .type(tokenSyntax):
                    "{\(tokenSyntax).\(name) = implicitCast(newValue)}"

                case .external, .value, .error:
                    "{\(staticInaccessiblePreconditionError)}"
                }

            default:
                throw UnsupportedAccessorError(accessor.accessorSpecifier.text)
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
                "set { self.\(baseName) = newValue }"
            } else {
                ""
            }

            accessor.body = if options.contains(.assureNoAssociates) {
                "{\(tryKeyword)\(awaitKeyword)\(baseName).\(name)}"
            } else {
                if accessor.isThrowing {
                    """
                    {\
                    func \(name)_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(type) {\
                        var localBase: _OpenBase_ {\
                            get { self.\(baseName) as! _OpenBase_ }\
                            \(setter)\
                        };\
                        do {\
                            return try \(awaitKeyword)implicitCast(localBase.\(name))\
                        } catch let error {\
                            throw implicitCast(error)\
                        }\
                    };\
                    return try \(awaitKeyword)_openExistential(self.\(baseName), do: \(name)_genericOpen)\
                    }
                    """
                } else {
                    """
                    {\
                    func \(name)_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(type) {\
                        var localBase: _OpenBase_ {\
                            get { self.\(baseName) as! _OpenBase_ }\
                            \(setter)\
                        };\
                        return \(awaitKeyword)implicitCast(localBase.\(name))\
                    };\
                    return \(awaitKeyword)implicitCast(_openExistential(self.\(baseName), do: \(name)_genericOpen))\
                    }
                    """
                }
            }

        case "set":
            accessor.body = if options.contains(.assureNoAssociates) {
                "{\(baseName).\(name) = newValue}"
            } else {
                """
                {\
                func \(name)_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) {\
                    var localBase: _OpenBase_ {\
                        get { self.\(baseName) as! _OpenBase_ }\
                        set { self.\(baseName) = newValue }\
                    };\
                    localBase.\(name) = implicitCast(newValue)\
                };\
                _openExistential(self.\(baseName), do: \(name)_genericOpen)\
                }
                """
            }

        default:
            throw UnsupportedAccessorError(accessor.accessorSpecifier.text)
        }
    }
}

// MARK: - Subscript Implementation

private func addImplementationToSubscript(
    _ subscript: inout SubscriptDeclSyntax,
    baseName: TokenSyntax,
    protocolName: TypeSyntax,
    options globalOptions: TypeEraserOptions
) throws {
    guard `subscript`.accessorBlock != nil else {
        throw CompilerError("No accessor block found")
    }

    var accessorBlock: AccessorBlockSyntax {
        get { `subscript`.accessorBlock! }
        set { `subscript`.accessorBlock! = newValue }
    }

    guard case .accessors = accessorBlock.accessors else {
        throw CompilerError("No accessors found")
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
        throw InoutUnsupportedError()
    }

    let formattedParameters = `subscript`.formattedParameters {
        "implicitCast(\($0))"
    }

    let formattedParametersNotCasted = `subscript`.formattedParameters()

    let localOptions = try getOptions(decl: `subscript`)
    let options = globalOptions.union(localOptions)

    try transform(&accessors) { _, accessor in
        let awaitKeyword: TokenSyntax = accessor.isAsync ? "await " : ""
        let tryKeyword: TokenSyntax = accessor.isThrowing ? "try " : ""

        if let staticImplementation = try getStaticImplementationType(of: `subscript`) {
            switch accessor.accessorSpecifier.trimmedDescription {
            case "get":
                accessor.body = switch staticImplementation {
                case let .value(tokenSyntax) where options
                    .contains(.assureNoAssociates):
                    "{\(tokenSyntax)}"

                case let .value(tokenSyntax):
                    "{implicitCast(\(tokenSyntax))}"

                case let .type(tokenSyntax) where options
                    .contains(.assureNoAssociates):
                    "{\(tryKeyword)\(awaitKeyword)\(tokenSyntax)[\(raw: formattedParametersNotCasted)]}"

                case let .type(tokenSyntax):
                    "{\(tryKeyword)\(awaitKeyword)implicitCast(\(tokenSyntax)[\(raw: formattedParameters)])}"

                case .external, .error:
                    "{\(staticInaccessiblePreconditionError)}"
                }
            case "set":
                accessor.body = switch staticImplementation {
                case let .type(tokenSyntax):
                    "{\(tokenSyntax)[\(raw: formattedParameters)] = implicitCast(newValue)}"

                case .external, .value, .error:
                    "{\(staticInaccessiblePreconditionError)}"
                }
            default:
                throw UnsupportedAccessorError(accessor.accessorSpecifier.text)
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
                "set { self.\(baseName) = newValue }"
            } else {
                ""
            }

            accessor.body = if options.contains(.assureNoAssociates) {
                "{\(tryKeyword)\(awaitKeyword)\(baseName)[\(raw: formattedParametersNotCasted)]}"
            } else if `subscript`.isThrowing {
                """
                {\
                func subscript_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(`subscript`.returnType) {\
                    var localBase: _OpenBase_ {\
                        get { self.\(baseName) as! _OpenBase_ }\
                        \(setter)\
                    };\
                    do {\
                        return try \(awaitKeyword)implicitCast(localBase[\(raw: formattedParameters)])\
                    } catch let error {\
                        throw implicitCast(error)\
                    }\
                };\
                return try \(awaitKeyword)implicitCast(_openExistential(self.\(baseName), do: subscript_genericOpen))\
                }
                """
            } else {
                """
                {\
                func subscript_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) \(effectSpecifier)-> \(`subscript`.returnType) {\
                    var localBase: _OpenBase_ {\
                        get { self.\(baseName) as! _OpenBase_ }\
                        \(setter)\
                    };\
                    return \(awaitKeyword)implicitCast(localBase[\(raw: formattedParameters)])\
                };\
                return \(awaitKeyword)implicitCast(_openExistential(self.\(baseName), do: subscript_genericOpen))\
                }
                """
            }
        case "set":
            let setter: TokenSyntax = if accessor.isMutating {
                "set { self.\(baseName) = newValue }"
            } else {
                ""
            }

            accessor.body = if options.contains(.assureNoAssociates) {
                "{\(baseName)[\(raw: formattedParametersNotCasted)] = newValue}"
            } else {
                """
                {\
                func subscript_genericOpen<_OpenBase_: \(protocolName)>(_: _OpenBase_) {\
                    var localBase: _OpenBase_ {\
                        get { self.\(baseName) as! _OpenBase_ }\
                        \(setter)\
                    };\
                    return localBase[\(raw: formattedParameters)] = implicitCast(newValue)\
                };\
                _openExistential(self.\(baseName), do: subscript_genericOpen)\
                }
                """
            }
        default:
            throw UnsupportedAccessorError(accessor.accessorSpecifier.text)
        }
    }
}

// MARK: - Init Implementation

private func addImplementationToInit(
    _ initializer: inout InitializerDeclSyntax,
    baseName _: TokenSyntax,
    protocolName _: TypeSyntax,
    options globalOptions: TypeEraserOptions
) throws {
    initializer.fillEmptyInputParametersIfNeeded()

    let formattedParameters = initializer.formattedParameters {
        "implicitCast(\($0))"
    }

    let formattedParametersNotCasted = initializer.formattedParameters()

    guard !initializer.containsInoutParameter else {
        throw InoutUnsupportedError()
    }

    let awaitKeyword: TokenSyntax = initializer.isAsync ? "await " : ""
    let tryKeyword: TokenSyntax = initializer.isThrowing ? "try " : ""

    let localOptions = try getOptions(decl: initializer)
    let options = globalOptions.union(localOptions)

    initializer.body = if let staticImplementation = try getStaticImplementationType(of: initializer) {
        if initializer.isOptional {
            switch staticImplementation {
            case let .value(tokenSyntax) where options
                .contains(.assureNoAssociates):
                "{self = \(tokenSyntax)}"

            case let .value(tokenSyntax):
                "{self = implicitCast(\(tokenSyntax))}"

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
                "{\(staticInaccessiblePreconditionError)}"
            }
        } else {
            switch staticImplementation {
            case let .value(tokenSyntax) where options
                .contains(.assureNoAssociates):
                "{self = \(tokenSyntax)}"

            case let .value(tokenSyntax):
                "{self = implicitCast(\(tokenSyntax))}"

            case let .type(tokenSyntax) where options
                .contains(.assureNoAssociates):
                "{\(tryKeyword)\(awaitKeyword)self.init(\(tokenSyntax)(\(raw: formattedParametersNotCasted)))}"

            case let .type(tokenSyntax):
                "{\(tryKeyword)\(awaitKeyword)self.init(\(tokenSyntax)(\(raw: formattedParameters)))}"

            case .external, .error:
                "{\(staticInaccessiblePreconditionError)}"
            }
        }
    } else {
        "{}"
    }
}

private func getStaticImplementationType(
    of syntax: some WithAttributesSyntax & WithModifiersSyntax
//    node: AttributeSyntax
) throws -> StaticImplementationType? {
    guard syntax.isStatic else {
        return nil
    }

    let attribute = syntax.attributes
        .compactMap(AttributeSyntax.init)
        .first(where: { $0.name == "Implementation" })

    guard let attribute else {
        throw MacroError("Static requirements of type erased protocols must have an explicit implementation")
    }

    guard let list = LabeledExprListSyntax(attribute.arguments),
          let argument = list.first else {
        throw IndirectOptionAccessError()
    }

    if let memberAccess = MemberAccessExprSyntax(argument.expression) {
        let type = memberAccess.declName

        guard memberAccess.base == any(of: nil, "ImplementationBehavior") else {
            throw IndirectOptionAccessError()
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
            throw IndirectOptionAccessError()
        }

        let type = functionCall.calledExpression

        if let memberAccess = MemberAccessExprSyntax(type) {
            let type = memberAccess.declName

            guard memberAccess.base == any(of: nil, "ImplementationBehavior") else {
                throw IndirectOptionAccessError()
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

    throw IndirectOptionAccessError()
}
