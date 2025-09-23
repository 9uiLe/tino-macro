import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct MetadataMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 引数がない場合はエラーを発生させる
        guard node.arguments != nil else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: MetadataMacroError.missingArgument
                )
            )
            return []
        }
        
        let content = extractContent(from: node)
        
        guard let content = content, !content.isEmpty else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: MetadataMacroError.emptyArgument
                )
            )
            return []
        }

        let decl: DeclSyntax
        if content.contains("\n") {
            // 複数行の文字列：ブロックコメントとして展開
            decl = DeclSyntax(stringLiteral: "/** @Metadata:\n\(content)\n*/")
        } else {
            // 単一行の文字列：行コメントとして展開
            decl = DeclSyntax(stringLiteral: "/// @Metadata: \(content)")
        }

        return [decl]
    }

    // MARK: - ヘルパーメソッド

    /// Attribute から文字列コンテンツを取り出す
    /// - 例：`@Metadata("...")` または `@Metadata("""...""")`
    private static func extractContent(from node: AttributeSyntax) -> String? {
        guard let arguments = node.arguments else {
            return nil
        }

        // 形式1：文字列リテラルがそのまま渡されている場合
        if let literal = arguments.as(StringLiteralExprSyntax.self) {
            return extractStringSegments(from: literal)
        }

        // 形式2：通常の引数リストの先頭が文字列リテラルの場合（@Metadata(<first>)）
        if let labeledList = arguments.as(LabeledExprListSyntax.self),
           let first = labeledList.first?.expression.as(StringLiteralExprSyntax.self) {
            return extractStringSegments(from: first)
        }

        // 上記に当てはまらない場合はテキストをそのまま使用（安全なフォールバック）
        return arguments.trimmedDescription
    }

    /// 文字列リテラルのセグメントを結合して内容を取り出す
    private static func extractStringSegments(from literal: StringLiteralExprSyntax) -> String {
        var result = ""
        for segment in literal.segments {
            if let s = segment.as(StringSegmentSyntax.self) {
                result += s.content.text
            } else {
                // 文字列補間などはそのまま文字列表現を残す（例：\(value)）
                result += segment.description
            }
        }
        return result
    }
}

// MARK: - エラー定義

enum MetadataMacroError: String, DiagnosticMessage {
    case missingArgument = "@Metadata requires a string argument describing the metadata"
    case emptyArgument = "@Metadata requires a non-empty string argument"
    
    var message: String {
        return self.rawValue
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "MetadataMacro", id: self.rawValue)
    }
    
    var severity: DiagnosticSeverity {
        return .error
    }
}
