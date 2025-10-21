import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntaxMacros

public struct LocalizedTextMacro: ExpressionMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        guard let keyExpression = node.arguments.first?.expression else {
            throw LocalizedTextMacroError.missingArgument
        }

        // 呼び出しモジュールの .module を生成コードに埋め込む
        return "Text(\(keyExpression), bundle: .module)"
    }
}

// MARK: - Error

enum LocalizedTextMacroError: Error, CustomStringConvertible {
    case missingArgument

    var description: String {
        "Missing localization key argument."
    }
}
