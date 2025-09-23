/// A marker macro for embedding human-readable context that expands to comments only.
///
/// Usage:
///
/// ```swift
/// @Metadata("ホーム画面")
///
/// @Metadata("""
/// このクラスは、API通信を汎用化したものです
/// """)
/// ```
@attached(peer)
public macro Metadata(_ content: String) = #externalMacro(
    module: "TinoMacroMacros",
    type: "MetadataMacro"
)
