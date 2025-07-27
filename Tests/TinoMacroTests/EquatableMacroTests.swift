import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(TinoMacroMacros)
    import TinoMacroMacros

    nonisolated(unsafe) let equatableMacros: [String: Macro.Type] = [
        "equatable": EquatableMacro.self,
        "skipEquatable": SkipEquatableMacro.self,
    ]
#endif

final class EquatableMacroTests: XCTestCase {
    func equatableMacro() throws {
        #if canImport(TinoMacroMacros)
            assertMacroExpansion(
                """
                @Equatable
                struct User {
                    let name: String
                    let age: Int

                    @SkipEquatable var loggedIn: () -> Bool

                    init(name: String, age: Int, loggedIn: @escaping () -> Bool) {
                        self.name = name
                        self.age = age
                        self.loggedIn = loggedIn
                    }
                }
                """,
                expandedSource: """
                    struct User {
                        let name: String
                        let age: Int

                        @SkipEquatable var loggedIn: () -> Bool

                        init(name: String, age: Int, loggedIn: @escaping () -> Bool) {
                            self.name = name
                            self.age = age
                            self.loggedIn = loggedIn
                        }
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
}
