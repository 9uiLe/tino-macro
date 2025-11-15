import Foundation
import TinoMacro

@Equatable
struct User: Identifiable {
    let id = UUID()
    let name: String
    @SkipEquatable let age: Int

    @SkipEquatable var loggedIn: () -> Bool

    init(name: String, age: Int, loggedIn: @escaping () -> Bool) {
        self.name = name
        self.age = age
        self.loggedIn = loggedIn
    }
}

let userName = "John"
let loggedIn = User(name: userName, age: 30) { true }
let loggedOut = User(name: userName, age: 25) { false }
let copy = loggedIn

// クロージャは比較されずに、true になるはず
print(loggedIn == copy)
print(loggedIn == loggedOut)

enum L10n {
    /// LocalizedStringKey: home.header.title
    /// defaultValue: ホーム
    static let title = #L10n(
        "home.header.title",
        defaultValue: "ホーム"
    )
}
