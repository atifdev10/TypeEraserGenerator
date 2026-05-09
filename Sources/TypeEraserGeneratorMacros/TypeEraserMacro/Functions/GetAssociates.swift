import SwiftSyntax

struct Associate {
    var name: String
    var protocolName: String?

    var _eraser: String?

    var conformances: [String] {
        didSet { conformances = conformances.unique() }
    }

    init(
        _ name: String,
        conformances: [String] = [],
        eraser: String? = nil,
        protocolName: String? = nil
    ) {
        self.name = name
        self.conformances = conformances
        _eraser = eraser
        self.protocolName = protocolName
    }

    var eraser: String {
        get {
            if let _eraser {
                return _eraser
            }

            if conformances.isEmpty {
                return "Any"
            }

            if conformances.first == "Error" {
                return "any Error"
            }

            return "Any" + conformances.joined(separator: "And")
        }
        set {
            _eraser = newValue
        }
    }
}

@discardableResult
func getAssociates(
    _ members: MemberBlockItemListSyntax
) throws -> [Associate] {
    let decls = members
        .map(\.decl)

    var result = [Associate]()

    for decl in decls {
        if let associate = AssociatedTypeDeclSyntax(decl) {
            let associateName = associate.name.text
            let attachment = associate.attributes
                .compactMap(AttributeSyntax.init)
                .first { $0.name == "Erase" }

            let notErasedAssociateError = {
                MacroError("Associated type '\(associate.name.text)' does not have an associated eraser")
            }

            guard let attachment else {
                throw notErasedAssociateError()
            }

            guard let identifier = IdentifierTypeSyntax(attachment.attributeName) else {
                throw notErasedAssociateError()
            }

            let eraser = identifier.genericArgumentClause?.arguments
                .map(\.argument)
                .compactMap(TypeSyntax.init)
                .first?.trimmedDescription

            if let eraser {
                result.append(Associate(associateName, eraser: eraser))
                continue
            }

            guard let inheritanceClause = associate.inheritanceClause else {
                result.append(Associate(associateName))
                continue
            }

            result.append(Associate(
                associateName,
                conformances: inheritanceClause.inheritedTypes
                    .map(\.type.trimmedDescription)
                    .joined(separator: "&")
                    .replacingOccurrences(of: " & ", with: "&")
                    .replacingOccurrences(of: "& ", with: "&")
                    .components(separatedBy: "&")
            ))
        }

        if let type = decl.asProtocol((any WithAttributesSyntax).self) {
            let attachments = type.attributes
                .compactMap(AttributeSyntax.init)
                .filter { $0.name == any(of: "Associate", "AssociateEraser") }

            for attachment in attachments {
                guard let identifier = IdentifierTypeSyntax(attachment.attributeName) else {
                    fatalError()
                }

                let associateName = {
                    let literal = LabeledExprListSyntax(attachment.arguments)!
                        .first!.expression

                    guard let literal = StringLiteralExprSyntax(literal) else {
                        fatalError()
                    }

                    return literal.segments.trimmedDescription
                }()

                let arguments = identifier.genericArgumentClause?.arguments
                    .map(\.argument)
                    .compactMap(TypeSyntax.init)

                guard let arguments else {
                    result.append(Associate(associateName))
                    continue
                }

                if attachment.name == "AssociateEraser" {
                    result.append(Associate(
                        associateName,
                        eraser: arguments.last!.trimmedDescription
                    ))
                    continue
                }

                let anyTypes = arguments.compactMap(SomeOrAnyTypeSyntax.init)

                guard anyTypes.count == arguments.count else {
                    throw ProtocolAnyPrefixError()
                }

                result.append(Associate(
                    associateName,
                    conformances: anyTypes
                        .map(\.constraint.trimmedDescription)
                        .joined(separator: "&")
                        .replacingOccurrences(of: " & ", with: "&")
                        .replacingOccurrences(of: "& ", with: "&")
                        .components(separatedBy: "&")
                ))
            }
        }
    }

    return result
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        var buffer = [Element]()
        var added = Set<Element>()

        for element in self {
            if !added.contains(element) {
                buffer.append(element)
                added.insert(element)
            }
        }

        return buffer
    }
}
