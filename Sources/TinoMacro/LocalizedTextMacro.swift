import SwiftUI

/// Swift Package Manager でモジュールごとに String Catalog を利用するためのマクロ
@freestanding(expression)
public macro LocalizedText(
    key: LocalizedStringKey
) = #externalMacro(module: "TinoMacroMacros", type: "LocalizedTextMacro")
