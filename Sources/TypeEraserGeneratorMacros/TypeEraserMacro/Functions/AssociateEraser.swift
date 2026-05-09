import MultiModule
import SwiftSyntax

struct AssociateEraserDeclaration {
    var associate: Associate
    var subErasers: [AssociateEraserDeclaration] = []

    func decl(options: TypeEraserOptions) -> DeclSyntax {
        if subErasers.isEmpty {
            return "typealias \(raw: associate.name) = \(raw: associate.eraser)"
        }

        let composition = associate.conformances.joined(separator: "&")

        let conformances = associate.conformances
            .map {
                if options.contains(.disableEraserInheritance) {
                    $0
                } else {
                    "Erased\($0)"
                }
            }
            .joined(separator: ",")

        let conformanceList = if conformances.isEmpty {
            ""
        } else {
            ", \(conformances)"
        }

        let compositionConformance = if conformances.isEmpty {
            "Any"
        } else {
            composition
        }

        return """
        struct \(raw: associate.name): TypeEraser\(raw: conformanceList) {
            /// The value wrapped by this instance.
            var base: any \(raw: compositionConformance)
            /// Create an instance that type-erases `\(raw: compositionConformance)`.
            init(_ erasing: some \(raw: compositionConformance)) {
                self.base = erasing
            }
            /// Create an instance that type-erases `\(raw: compositionConformance)`.
            init(erasing: any \(raw: compositionConformance)) {
                self.base = erasing
            }
            \(subErasers.first!.decl(options: options))
        }
        """
    }
}

func createNecessaryErasers(
    _ constraints: [WhereRequirement]
) throws -> [AssociateEraserDeclaration] {
    var erasers = [AssociateEraserDeclaration]()

    for case let .conforms(conform) in constraints {
        var currentAccess: WritableKeyPath<[AssociateEraserDeclaration],
            AssociateEraserDeclaration>

        let index = erasers.firstIndex {
            $0.associate.name == conform.associateName.names.first!
        }

        if let index {
            currentAccess = \.[index]
        } else {
            erasers.append(.init(associate: .init(
                conform.associateName.names.first!,
                conformances: conform.conformances
            )))

            currentAccess = \.[erasers.count - 1]
        }

        for name in conform.associateName.names.dropFirst() {
            var index: Int! = erasers[keyPath: currentAccess].subErasers
                .firstIndex { $0.associate.name == name }

            if index == nil {
                erasers[keyPath: currentAccess].subErasers
                    .append(.init(associate: .init(name)))

                index = erasers[keyPath: currentAccess].subErasers.count - 1
            }

            currentAccess = currentAccess.appending(path: \.subErasers[index])
        }

        erasers[keyPath: currentAccess].associate.conformances
            .append(contentsOf: conform.conformances)
    }

    for case let .equals(equal) in constraints {
        var currentAccess: WritableKeyPath<[AssociateEraserDeclaration],
            AssociateEraserDeclaration>

        let index = erasers.firstIndex {
            $0.associate.name == equal.associateName.names.first!
        }

        if let index {
            currentAccess = \.[index]
        } else {
            erasers.append(.init(associate:
                .init(equal.associateName.names.first!)))

            currentAccess = \.[erasers.count - 1]
        }

        for name in equal.associateName.names.dropFirst() {
            var index: Int! = erasers[keyPath: currentAccess].subErasers
                .firstIndex { $0.associate.name == name }

            if index == nil {
                erasers[keyPath: currentAccess].subErasers
                    .append(.init(associate: .init(name)))

                index = erasers[keyPath: currentAccess].subErasers.count - 1
            }

            currentAccess = currentAccess.appending(path: \.subErasers[index])
        }

        erasers[keyPath: currentAccess].associate.eraser = equal.equal
    }

    return erasers
}
