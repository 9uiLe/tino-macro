import TinoMacro

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

let userName = "John"
let age = 30
let loggedIn = User(name: userName, age: age) { true }
let loggedOut = User(name: userName, age: age) { false }
let copy = loggedIn

// クロージャは比較されずに、true になるはず
print(loggedIn == copy)
print(loggedIn == loggedOut)
