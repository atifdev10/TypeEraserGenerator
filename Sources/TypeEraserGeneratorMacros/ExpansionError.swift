import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// TODO: Better error names

enum ExpansionError: Error, CustomStringConvertible {
    case protocolsOnly
    case incorrectOptions
    case incorrectDefault
    case memberOfProtocolOnly
    case onlyApplicableToStatics
    case onlyApplicableToAssociates
    case protocolNotMarked
    case onlyOneDefaultAllowed
    case onlyOneOptionAllowed
    case setterNotAllowed
    case notApplicableToInitAndAssociated
    case inoutNotSupportedYet
    case accessorImplementationMissing

    case notSupportedDecl(kind: SyntaxKind)
    case associatedMustHaveErasureSpecifier(associated: String)
    case notSupported(kind: any Sendable)
    case notSupportedAccessor(_ accessor: String)

    case internalError(_ string: String)
    case compilerError(_ string: String)

    @available(*, deprecated, message: "Don't forget to delete")
    case __log(_ any: any Sendable)

    var description: String {
        switch self {
        case .protocolsOnly:
            "Only protocols are type erasable"

        case .incorrectOptions:
            "Options should only have direct accesses to options"

        case .incorrectDefault:
            "Default should only have direct accesses to defaults"

        case .memberOfProtocolOnly:
            "Only static requirements of protocol can have a default"

        case .onlyApplicableToStatics:
            "Only static requirements can have a default"

        case .onlyApplicableToAssociates:
            "Only associated types can have a erasure specifier"

        case .protocolNotMarked:
            "Protocol isn't marked to be type erased"

        case .onlyOneDefaultAllowed:
            "Requirement can only have one default"

        case .onlyOneOptionAllowed:
            "Requirement can only have one option specifier"

        case .setterNotAllowed:
            "This default doesn't support the use of set requirement"

        case .notApplicableToInitAndAssociated:
            "This macro isn't applicable to initializers and associated types"

        case .inoutNotSupportedYet:
            "Inout parameters are not supported yet"

        case .accessorImplementationMissing:
            "Implementation for the second accessor is missing"

        case let .notSupportedDecl(kind):
            "Not supported: \(kind)"

        case let .associatedMustHaveErasureSpecifier(associated):
            "Associated type '\(associated)' must have a erasure specifier"

        case let .notSupported(kind):
            "Not supported: \(kind)"

        case let .notSupportedAccessor(accessor):
            "Accessor '\(accessor)' is not supported yet"

        case let .internalError(string):
            "Internal Error: \(string)"

        case let .compilerError(string):
            "Compiler Error: \(string)"

        case let .__log(any):
            "Result: \(any)"
        }
    }
}

enum ExpansionDiagnostic {
    static func noStaticsAllowed(node: AttributeSyntax) -> Diagnostic {
        Diagnostic(
            node: Syntax(node),
            message: MacroExpansionErrorMessage("Type erased protocols can't have static requirements"),
            notes: [
                Note(
                    node: Syntax(node),
                    message: MacroExpansionNoteMessage("Add a default specifier")
                ),
                Note(
                    node: Syntax(node),
                    message: MacroExpansionNoteMessage("Make the requirements non-static")
                ),
                Note(
                    node: Syntax(node),
                    message: MacroExpansionNoteMessage("Split the static requirements into an another protocol")
                ),
            ]
        )
    }
}
