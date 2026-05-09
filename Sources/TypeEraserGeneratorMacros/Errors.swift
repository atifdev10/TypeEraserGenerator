import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

typealias MacroErrorProtocol = CustomStringConvertible & Error
typealias MacroError = MacroExpansionErrorMessage

struct InternalError: MacroErrorProtocol {
    var message: String

    init(_ message: String) {
        self.message = message
    }

    var description: String {
        "Internal error: " + message
    }
}

struct CompilerError: MacroErrorProtocol {
    var message: String

    init(_ message: String) {
        self.message = message
    }

    var description: String {
        "Compiler error: " + message
    }
}

struct IndirectOptionAccessError: MacroErrorProtocol {
    var description: String {
        "Indirect access to option"
    }
}

struct NotProtocolRequirementError: MacroErrorProtocol {
    var description: String {
        "Declaration is not a protocol requirement"
    }
}

struct NotTypeErasedProtocolError: MacroErrorProtocol {
    var description: String {
        "Protocol is not type erased"
    }
}

struct ProtocolAnyPrefixError: MacroErrorProtocol {
    var description: String {
        "The protocols must be prefixed with 'any'"
    }
}

@available(*, deprecated, message: "Don't forget to delete")
struct Log: MacroErrorProtocol {
    var message: String

    init(_ message: String) {
        self.message = message
    }

    var description: String {
        "Log: " + message
    }
}
