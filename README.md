# Tino Macro

## Overview

- Tino アプリで利用するマクロ定義

## Macros

### Equatable

- `@Equatable` を付与することで、オブジェクトを Equatable に適合させます
- `@SkipEquatable` をプロパティに付与することで比較条件から対象を除外することができます
- SwiftUI.View の body は比較されません

**✅ 利用方法**

```swift
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
```

### L10n

- String Catalog を扱いやすくするためのマクロです
- `#L10n` を利用してビルドすることで、`Localized.xcstrings` に Key & Value を生成します
- `Bundle` はデフォルトが `.module`、必要に応じて `.main` に切り替えてください

**✅ 利用方法**

```swift
static let title = #L10n("home.title", defaultValue: "ホーム")

// 以下が生成されます
static let title = LocalizedStringResource(
    "home.title",
    defaultValue: String.LocalizationValue("ホーム"),
    bundle: .module
)
```
