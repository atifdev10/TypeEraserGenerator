import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct TypeEraserGeneratorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TypeEraserMacro.self,
        DefaultMacro.self,
        EraseMacro.self,
        OptionsMacro.self,
    ]
}
