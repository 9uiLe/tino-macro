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
