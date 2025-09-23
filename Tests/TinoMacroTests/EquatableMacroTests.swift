import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(TinoMacroMacros)
    import TinoMacroMacros

    nonisolated(unsafe) let equatableMacros: [String: Macro.Type] = [
        "Equatable": EquatableMacro.self,
        "SkipEquatable": SkipEquatableMacro.self,
    ]
#endif

@Suite("Equatable Macro Test")
struct EquatableMacroTests {
    @Test("Equatable Macro の基本機能")
    func testEquatableMacro() throws {
        #if canImport(TinoMacroMacros)
            assertMacroExpansion(
                """
                @Equatable
                struct User {
                    let name: String
                    let age: Int

                    @SkipEquatable var loggedIn: () -> Bool
                }
                """,
                expandedSource: """
                    struct User {
                        let name: String
                        let age: Int

                        var loggedIn: () -> Bool
                    }

                    extension User: Equatable {
                        public static func == (lhs: User, rhs: User) -> Bool {
                            return lhs.name == rhs.name && lhs.age == rhs.age
                        }
                    }
                    """,
                macros: equatableMacros
            )
        #else
            throw TestSkipError(
                "マクロはホストプラットフォーム用のテスト実行時にのみサポートされています"
            )
        #endif
    }

    @Test("プロパティが存在しない場合")
    func testNoProperty() throws {
        #if canImport(TinoMacroMacros)
            assertMacroExpansion(
                """
                @Equatable
                struct User {}
                """,
                expandedSource: """
                    struct User {}

                    extension User: Equatable {
                        public static func == (lhs: User, rhs: User) -> Bool {
                            return true
                        }
                    }
                    """,
                macros: equatableMacros
            )
        #else
            throw TestSkipError(
                "マクロはホストプラットフォーム用のテスト実行時にのみサポートされています"
            )
        #endif
    }

    @Test("SwiftUI.View が extension されていない場合は、body を除外しない")
    func testNoViewExtension() throws {
        #if canImport(TinoMacroMacros)
            assertMacroExpansion(
                """
                @Equatable
                struct User {
                    let name: String
                    let age: Int
                    let body: String

                    @SkipEquatable var loggedIn: () -> Bool
                }
                """,
                expandedSource: """
                    struct User {
                        let name: String
                        let age: Int
                        let body: String

                        var loggedIn: () -> Bool
                    }

                    extension User: Equatable {
                        public static func == (lhs: User, rhs: User) -> Bool {
                            return lhs.name == rhs.name && lhs.age == rhs.age && lhs.body == rhs.body
                        }
                    }
                    """,
                macros: equatableMacros
            )
        #else
            throw TestSkipError(
                "マクロはホストプラットフォーム用のテスト実行時にのみサポートされています"
            )
        #endif
    }

    @Test("View body 除外テスト")
    func testExcludeViewBody() throws {
        #if canImport(TinoMacroMacros)
            assertMacroExpansion(
                """
                @Equatable
                struct UserView: View {
                    let name: String
                    let age: Int

                    @SkipEquatable var loggedIn: () -> Bool

                    var body: some View {
                        VStack {
                            Text(name)
                            Text(age)
                        }
                    }
                }
                """,
                expandedSource: """
                    struct UserView: View {
                        let name: String
                        let age: Int

                        var loggedIn: () -> Bool

                        var body: some View {
                            VStack {
                                Text(name)
                                Text(age)
                            }
                        }
                    }

                    extension UserView: Equatable {
                        public static func == (lhs: UserView, rhs: UserView) -> Bool {
                            return lhs.name == rhs.name && lhs.age == rhs.age
                        }
                    }
                    """,
                macros: equatableMacros
            )
        #else
            throw TestSkipError(
                "マクロはホストプラットフォーム用のテスト実行時にのみサポートされています"
            )
        #endif
    }
}
