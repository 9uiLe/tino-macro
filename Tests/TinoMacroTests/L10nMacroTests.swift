import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@testable import TinoMacroMacros

// Helper to register macros under the name used in source: #L10n
@MainActor
private let testMacros: [String: Macro.Type] = [
    "L10n": L10nMacro.self
]

@Suite("L10nMacro Expansion Tests")
@MainActor struct L10nMacroTests {
    @Test("Expands with default bundle (.module) when bundle arg omitted")
    func expandsWithDefaultBundle() async throws {
        assertMacroExpansion(
            "#L10n(\"home.title\", \"ホーム\")",
            expandedSource: """
                LocalizedStringResource(
                    "home.title",
                    defaultValue: String.LocalizationValue("ホーム"),
                    bundle: Bundle.module
                )
                """,
            macros: testMacros
        )
    }

    @Test("Expands with explicit .module bundle")
    func expandsWithModuleBundle() async throws {
        assertMacroExpansion(
            "#L10n(\"home.title\", \"ホーム\", bundle: .module)",
            expandedSource: """
                LocalizedStringResource(
                    "home.title",
                    defaultValue: String.LocalizationValue("ホーム"),
                    bundle: Bundle.module
                )
                """,
            macros: testMacros
        )
    }

    @Test("Expands with explicit .main bundle")
    func expandsWithMainBundle() async throws {
        assertMacroExpansion(
            "#L10n(\"home.title\", \"ホーム\", bundle: .main)",
            expandedSource: """
                LocalizedStringResource(
                    "home.title",
                    defaultValue: String.LocalizationValue("ホーム"),
                    bundle: Bundle.main
                )
                """,
            macros: testMacros
        )
    }

    @Test("Errors when insufficient arguments are provided")
    func errorsOnInsufficientArguments() async throws {
        assertMacroExpansion(
            "#L10n(\"onlyKey\")",
            expandedSource: "#L10n(\"onlyKey\")",
            diagnostics: [
                .init(
                    message:
                        "#L10n requires at least `key` and `default` arguments",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }

    @Test("Errors when key is not a string literal")
    func errorsOnNonStringKey() async throws {
        assertMacroExpansion(
            "#L10n(123, \"default\")",
            expandedSource: "#L10n(123, \"default\")",
            diagnostics: [
                .init(
                    message:
                        "First argument to #L10n must be a string literal key",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }

    @Test("Errors when default is not a string literal")
    func errorsOnNonStringDefault() async throws {
        assertMacroExpansion(
            "#L10n(\"key\", 999)",
            expandedSource: "#L10n(\"key\", 999)",
            diagnostics: [
                .init(
                    message:
                        "`default` argument to #L10n must be a string literal",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }

    @Test("Errors when bundle expression is unsupported")
    func errorsOnUnsupportedBundle() async throws {
        assertMacroExpansion(
            "#L10n(\"key\", \"value\", bundle: someUnknownBundle)",
            expandedSource:
                "#L10n(\"key\", \"value\", bundle: someUnknownBundle)",
            diagnostics: [
                .init(
                    message:
                        "Unsupported bundle expression for #L10n: someUnknownBundle",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
}
