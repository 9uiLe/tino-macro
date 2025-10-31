import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct TinoMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EquatableMacro.self,
        SkipEquatableMacro.self
    ]
}
