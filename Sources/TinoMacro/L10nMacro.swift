import Foundation

public enum ResourceBundle {
    case main
    case module
}

/// "@LocalizedStringResourceKey" マクロを定義
/// Localizable.xcstrings のキーから LocalizedStringResource を生成する extension/置換を追加する
/// 使用例:
///   @L10n("home.header.title", defaultValue: "ホーム")
///   static let title: LocalizedStringResource
/// 展開後:
///   LocalizedStringResource(
///       "home.header.title",
///       defaultValue: String.LocalizationValue("ホーム"),
///       bundle: .module
///   )
@freestanding(expression)
public macro L10n(
    _ key: StaticString,
    defaultValue: String,
    bundle: ResourceBundle = .module
) -> LocalizedStringResource = #externalMacro(module: "TinoMacroMacros", type: "L10nMacro")
