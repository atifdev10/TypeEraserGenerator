import SwiftSyntaxMacros

#if canImport(TypeEraserGeneratorMacros)
    @testable import TypeEraserGeneratorMacros

    let testMacros: [String: Macro.Type] = [
        "TypeErased": TypeEraserMacro.self,
        "Erase": EraseMacro.self,
        "Default": DefaultMacro.self,
        "Options": OptionsMacro.self,
    ]
#else
    #error("Run on the host machine")
#endif
