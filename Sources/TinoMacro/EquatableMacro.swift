/// "@Equatable" という名前のマクロを定義
/// Equatable プロトコルに準拠させる extension を追加する
@attached(extension, conformances: Equatable, names: named(==))
public macro Equatable() =
    #externalMacro(module: "TinoMacroMacros", type: "EquatableMacro")

/// "@SkipEquatable" という名前のマクロを定義
/// "@Equatable" マクロで判定しないプロパティの修飾子として利用する
/// 内部的に処理は行わない
@attached(peer)
public macro SkipEquatable() =
    #externalMacro(module: "TinoMacroMacros", type: "SkipEquatableMacro")
