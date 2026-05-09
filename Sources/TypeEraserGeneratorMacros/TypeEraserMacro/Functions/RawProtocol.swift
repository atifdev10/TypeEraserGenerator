import SwiftSyntax

private let notProtocolError = { @Sendable in
    MacroError("Cannot type erase a non-protocol type")
}

func getRawProtocol(
    from decl: some DeclSyntaxProtocol,
    node: AttributeSyntax
) throws -> ProtocolDeclSyntax {
    guard var `protocol` = ProtocolDeclSyntax(decl) else {
        throw notProtocolError()
    }

    `protocol`.attributes.remove { element in
        element.trimmedDescription == node.trimmedDescription
    }

    return `protocol`
}

func asProtocol(from decl: String) throws -> ProtocolDeclSyntax {
    let decl: DeclSyntax = "\(raw: decl)"

    guard let `protocol` = ProtocolDeclSyntax(decl) else {
        throw notProtocolError()
    }

    return `protocol`
}
