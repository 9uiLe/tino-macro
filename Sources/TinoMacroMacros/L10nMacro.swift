import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private enum L10nMacroError: Error, CustomStringConvertible {
    /// 引数が足りない (#l10n("key", default: ...) の形になっていない)
    case insufficientArguments

    /// key が文字列リテラルではない
    case keyMustBeStringLiteral

    /// default が文字列リテラルではない
    case defaultMustBeStringLiteral

    /// サポートされていない Bundle
    case unsupportedBundleExpression(String)

    var description: String {
        switch self {
        case .insufficientArguments:
            return "#L10n requires at least `key` and `default` arguments"

        case .keyMustBeStringLiteral:
            return "First argument to #L10n must be a string literal key"

        case .defaultMustBeStringLiteral:
            return "`default` argument to #L10n must be a string literal"

        case let .unsupportedBundleExpression(bundleName):
            return "Unsupported bundle expression for #L10n: \(bundleName)"
        }
    }
}

/// "@LocalizedStringResourceKey" マクロを定義
/// Localizable.xcstrings のキーから LocalizedStringResource を生成する置換を追加する
/// 使用例:
///   @LocalizedStringResourceKey("home.header.title")
///   static let title: String = "ホーム"
/// 展開後:
///   static let title = LocalizedStringResource(
///       "home.header.title",
///       defaultValue: String.LocalizationValue("ホーム"),
///       bundle: .module
///   )
public struct L10nMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {

        // 引数をパースする
        let arguments = node.arguments

        guard arguments.count >= 2 else {
            throw L10nMacroError.insufficientArguments
        }

        // 1個目: key（ラベルなし）
        let keyArg = arguments[arguments.startIndex]
        // 2個目: default 引数
        let defaultArg = arguments[arguments.index(after: arguments.startIndex)]

        // key / default が string literal であることを軽くチェック
        guard keyArg.expression.is(StringLiteralExprSyntax.self) else {
            throw L10nMacroError.keyMustBeStringLiteral
        }

        guard defaultArg.expression.is(StringLiteralExprSyntax.self) else {
            throw L10nMacroError.defaultMustBeStringLiteral
        }

        let bundleExpr: ExprSyntax
        if let bundleArg = arguments.first(where: { $0.label?.text == "bundle" }) {
            let text = bundleArg.expression.trimmedDescription

            switch text {
            case ".main", "ResourceBundle.main":
                bundleExpr = "Bundle.main"

            case ".module", "ResourceBundle.module":
                bundleExpr = "Bundle.module"

            default:
                // より柔軟にしたければ、そのまま通す or エラーにする
                // ここではひとまずエラーにしておく
                throw L10nMacroError.unsupportedBundleExpression(text)
            }
        } else {
            // bundle 引数が省略された場合のデフォルト
            bundleExpr = "Bundle.module"
        }

        // 実際に展開する式を組み立てる
        // LocalizedStringResource(
        //   <key>,
        //   defaultValue: String.LocalizationValue(<default>),
        //   bundle: <bundle>
        // )
        let expanded: ExprSyntax = """
        LocalizedStringResource(
            \(keyArg.expression),
            defaultValue: String.LocalizationValue(\(defaultArg.expression)),
            bundle: \(bundleExpr)
        )
        """

        return expanded
    }
}
