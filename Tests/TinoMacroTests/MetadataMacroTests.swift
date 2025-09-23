import Testing
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

#if canImport(TinoMacroMacros)
import TinoMacroMacros

nonisolated(unsafe) let metadataMacros: [String: Macro.Type] = [
    "Metadata": MetadataMacro.self,
]
#endif

@Suite("MetadataMacro テスト")
struct MetadataMacroTests {
    @Test("単一行コンテンツがドキュメンテーションコメントピアに展開される")
    func singleLine() throws {
        #if canImport(TinoMacroMacros)
        assertMacroExpansion(
            """
            @Metadata("ホーム画面")
            struct Home {}
            """,
            expandedSource: """
            /// @Metadata: ホーム画面
            struct Home {}
            """,
            macros: metadataMacros
        )
        #else
        Issue.record("TinoMacroMacros モジュールがインポートできませんでした")
        #endif
    }

    @Test("複数行コンテンツがドキュメンテーションブロックコメントピアに展開される")
    func multiline() throws {
        #if canImport(TinoMacroMacros)
        assertMacroExpansion(
            """
            @Metadata(\"\"\"
            複数行
            のメタデータ
            \"\"\")
            struct Home {}
            """,
            expandedSource: """
            /** @Metadata:
            複数行
            のメタデータ
            */
            struct Home {}
            """,
            macros: metadataMacros
        )
        #else
        Issue.record("TinoMacroMacros モジュールがインポートできませんでした")
        #endif
    }

    @Test("引数なしの場合は診断エラーが発生する")
    func noArgument() throws {
        #if canImport(TinoMacroMacros)
        assertMacroExpansion(
            """
            @Metadata
            struct Home {}
            """,
            expandedSource: """
            struct Home {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Metadata requires a string argument describing the metadata",
                    line: 1,
                    column: 1,
                    severity: .error
                )
            ],
            macros: metadataMacros
        )
        #else
        Issue.record("TinoMacroMacros モジュールがインポートできませんでした")
        #endif
    }

    @Test("文字列補間がドキュメンテーションコメント出力で保持される")
    func interpolationPreserved() throws {
        #if canImport(TinoMacroMacros)
        assertMacroExpansion(
            """
            @Metadata("Hello \\(name)")
            struct Home {}
            """,
            expandedSource: """
            /// @Metadata: Hello \\(name)
            struct Home {}
            """,
            macros: metadataMacros
        )
        #else
        Issue.record("TinoMacroMacros モジュールがインポートできませんでした")
        #endif
    }
}
