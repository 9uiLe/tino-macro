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

// MARK: - @Metadata サンプルコード

@Metadata("ユーザープロフィール画面")
struct ProfileView {
    let user: User
}

@Metadata("""
アプリのホーム画面
メインナビゲーションを提供
ユーザーの主要な操作を表示
""")
struct HomeView {
    let currentUser: User
    let isLoggedIn: Bool
}

@Metadata("アプリケーション設定画面")
struct SettingsView {
    let configuration: [String: Any]
}

@Metadata("設定項目: \(userName) のプリファレンス")
struct UserPreferences {
    let userId: UUID
    let darkMode: Bool
    let notifications: Bool
    
    init(for user: User, darkMode: Bool = false, notifications: Bool = true) {
        self.userId = user.id
        self.darkMode = darkMode
        self.notifications = notifications
    }
}

// @Metadataのサンプルインスタンス作成
let profileView = ProfileView(user: loggedIn)
let homeView = HomeView(currentUser: loggedIn, isLoggedIn: loggedIn.loggedIn())
let settingsView = SettingsView(configuration: ["theme": "light"])
let userPrefs = UserPreferences(for: loggedIn, darkMode: true)

print("ProfileView for user: \(profileView.user.name)")
print("HomeView logged in status: \(homeView.isLoggedIn)")
print("UserPreferences for \(userPrefs.userId): dark mode = \(userPrefs.darkMode)")
