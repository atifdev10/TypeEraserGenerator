import SwiftSyntaxMacros
import SwiftSyntax
import MultiModule
import Foundation

extension TypeEraserMacro: ExtensionMacro {
    static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let prot: ProtocolDeclSyntax

        do {
            prot = try getRawProtocol(from: declaration, node: node)
        } catch {
            return []
        }

        let globalOptions = try getOptionsFromTypeEraser(node: node)

        var newDecls = prot.memberBlock.members.map(\.decl)

        var pendingRemovalIndexes = [Int]()

        try transform(&newDecls) { index, decl in
            let localOptions = try getOptionsFromDecl(decl: decl)

            let options = globalOptions.union(localOptions)

            guard options.contains(.exportStaticToObjectLevel) else {
                pendingRemovalIndexes.append(index)
                throw LoopWorkflow.continue
            }

            guard let nonStaticDecl = checkStaticAndReturnNonStatic(decl) else {
                pendingRemovalIndexes.append(index)
                throw LoopWorkflow.continue
            }

            decl = nonStaticDecl

            try addImplementation(&decl, options: options)

            removeHelperMacros(&decl)
        }

        newDecls.remove(bulk: pendingRemovalIndexes)

        let newMembers = newDecls.map { MemberBlockItemSyntax(decl: $0) }

        guard !newMembers.isEmpty else {
            return []
        }

        return try [
            ExtensionDeclSyntax("extension \(type)") { newMembers },
        ]
    }

    private static func addImplementation(
        _ decl: inout DeclSyntax,
        options: TypeEraserOptions
    ) throws {
        switch decl.kind {
        case .functionDecl:
            withDeclSyntaxCast(
                &decl, to: FunctionDeclSyntax.self
            ) { function in
                let awaitKeyword: TokenSyntax = function.isAsync ? "await " : ""
                let tryKeyword: TokenSyntax = function.isThrowing ? "try " : ""

                function.fillEmptyInputParametersIfNeeded()

                if options.contains(.assureNoAssociates) {
                    let formattedParameters = function.formattedParameters()

                    function.body = "{\(tryKeyword)\(awaitKeyword)Self.\(function.name)(\(raw: formattedParameters))}"
                    return
                }

                let formattedParameters = function.formattedParameters {
                    "__implicitCast(\($0))"
                }

                function.body = "{\(tryKeyword)\(awaitKeyword)__implicitCast(Self.\(function.name)(\(raw: formattedParameters)))}"
            }

        case .variableDecl:
            try withDeclSyntaxCast(
                &decl, to: VariableDeclSyntax.self
            ) { variable in
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

                try transform(&accessors) { _, accessor in
                    let awaitKeyword: TokenSyntax = accessor.isAsync ? "await " : ""
                    let tryKeyword: TokenSyntax = accessor.isThrowing ? "try " : ""

                    let name = IdentifierPatternSyntax(binding.pattern)!.identifier


                    if options.contains(.assureNoAssociates) {
                        switch accessor.accessorSpecifier.trimmedDescription {
                        case "get":
                            accessor.body = "{\(tryKeyword)\(awaitKeyword)Self.\(name)}"
                        case "set":
                            accessor.body = "{\(tryKeyword)\(awaitKeyword)Self.\(name) = newValue}"
                        default:
                            throw ExpansionError.notSupportedAccessor(
                                accessor.accessorSpecifier.text
                            )
                        }

                        throw LoopWorkflow.continue
                    }

                    switch accessor.accessorSpecifier.trimmedDescription {
                    case "get":
                        accessor.body = "{\(tryKeyword)\(awaitKeyword)__implicitCast(Self.\(name))}"
                    case "set":
                        accessor.body = "{\(tryKeyword)\(awaitKeyword)Self.\(name) = __implicitCast(newValue)}"
                    default:
                        throw ExpansionError.notSupportedAccessor(
                            accessor.accessorSpecifier.text
                        )
                    }
                }
            }

        case .subscriptDecl:
            var `subscript`: SubscriptDeclSyntax {
                get { decl.cast(SubscriptDeclSyntax.self) }
                set { decl = DeclSyntax(newValue) }
            }

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

            try transform(&accessors) { _, accessor in
                let awaitKeyword: TokenSyntax = accessor.isAsync ? "await " : ""
                let tryKeyword: TokenSyntax = accessor.isThrowing ? "try " : ""

                if options.contains(.assureNoAssociates) {
                    switch accessor.accessorSpecifier.trimmedDescription {
                    case "get":
                        accessor.body = "{\(tryKeyword)\(awaitKeyword)Self[\(raw: formattedParametersNotCasted)]}"
                    case "set":
                        accessor.body = "{\(tryKeyword)\(awaitKeyword)Self[\(raw: formattedParametersNotCasted)] = newValue}"
                    default:
                        throw ExpansionError.notSupportedAccessor(
                            accessor.accessorSpecifier.text
                        )
                    }

                    throw LoopWorkflow.continue
                }

                switch accessor.accessorSpecifier.trimmedDescription {
                case "get":
                    accessor.body = "{\(tryKeyword)\(awaitKeyword)Self[\(raw: formattedParameters)]}"
                case "set":
                    accessor.body = "{\(tryKeyword)\(awaitKeyword)Self[\(raw: formattedParameters)] = __implicitCast(newValue)}"
                default:
                    throw ExpansionError.notSupportedAccessor(
                        accessor.accessorSpecifier.text
                    )
                }
            }

        case .initializerDecl: break
        case .typeAliasDecl: break
        case .associatedTypeDecl: break

        default:
            throw ExpansionError.notSupportedDecl(kind: decl.kind)
        }
    }
}
