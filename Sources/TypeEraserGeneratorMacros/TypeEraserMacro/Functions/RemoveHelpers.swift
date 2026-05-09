import SwiftSyntax

func removeHelperMacros(_ syntax: inout DeclSyntax) {
    var attributedSyntax: any WithAttributesSyntax {
        get { syntax.asProtocol((any WithAttributesSyntax).self)! }
        set { syntax = "\(newValue)" }
    }

    attributedSyntax.attributes.remove { attribute in
        guard let attribute = AttributeSyntax(attribute) else {
            return false
        }

        return attachedHelperMacroNames.contains(attribute.name)
    }
}
