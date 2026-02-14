import SwiftSyntaxMacros

#if canImport(TypeEraserGeneratorMacros)
    @testable import TypeEraserGeneratorMacros

    let testMacros: [String: Macro.Type] = [
        "TypeErased": TypeEraserMacro.self,
        "ErasureType": ErasureMacro.self,
        "DefaultType": DefaultTypeMacro.self,
        "DefaultValue": DefaultValueMacro.self,
        "DefaultNone": DefaultNoneMacro.self,
    ]
#else
    #error("Run on the host machine")
#endif
