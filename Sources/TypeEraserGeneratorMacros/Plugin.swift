import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct TypeEraserGeneratorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TypeEraserMacro.self,
        DefaultTypeMacro.self,
        DefaultValueMacro.self,
        DefaultExternalMacro.self,
        DefaultNoneMacro.self,
        ErasureMacro.self,
    ]
}
