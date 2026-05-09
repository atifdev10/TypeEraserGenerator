import SwiftSyntaxMacros
import SwiftUI

#if canImport(TypeEraserGeneratorMacros)
    @testable import TypeEraserGeneratorMacros

    let testMacros: [String: Macro.Type] = [
        "TypeErased": TypeEraserMacro.self,
        "Implementation": ImplementationMacro.self,
        "Erase": EraseMacro.self,
        "Options": OptionsMacro.self,
        "compositionTypeEraser": CompositionMacro.self,
        "__TEExtend": TEExtendMacro.self,
        "typeErased": ExternalTypeEraserMacro.self,
        "Associate": AssociatedMacro.self,
        "AssociateEraser": AssociatedMacro.self,
    ]
#else
    #error("Run on the host machine")
#endif
