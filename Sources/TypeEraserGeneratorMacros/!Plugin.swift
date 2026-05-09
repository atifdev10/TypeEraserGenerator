import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct TypeEraserGeneratorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TypeEraserMacro.self,
        ImplementationMacro.self,
        EraseMacro.self,
        OptionsMacro.self,
        CompositionMacro.self,
        TEExtendMacro.self,
        ExternalTypeEraserMacro.self,
        AssociatedMacro.self,
    ]
}
