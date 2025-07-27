import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(TinoMacroMacros)
    import TinoMacroMacros

    nonisolated(unsafe) let equatableMacros: [String: Macro.Type] = [
        "Equatable": EquatableMacro.self,
        "SkipEquatable": SkipEquatableMacro.self,
    ]
#endif

final class EquatableMacroTests: XCTestCase {
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
            throw XCTSkip(
                "macros are only supported when running tests for the host platform"
            )
        #endif
    }

    /// プロパティが存在しない
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
            throw XCTSkip(
                "macros are only supported when running tests for the host platform"
            )
        #endif
    }

    /// SwiftUI.View が extension されていない場合は、body を除外しない
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
            throw XCTSkip(
                "macros are only supported when running tests for the host platform"
            )
        #endif
    }

    /// SwiftUI.View が extension されている場合は、body を除外する
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
            throw XCTSkip(
                "macros are only supported when running tests for the host platform"
            )
        #endif
    }
}
