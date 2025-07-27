import SwiftSyntax
import SwiftSyntaxMacros

public struct EquatableMacro: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        // 1. 構造体のプロパティを全て取得する
        let members = declaration.memberBlock.members
        let variableDecls = members.compactMap {
            $0.decl.as(VariableDeclSyntax.self)
        }

        // 2. "@SkipEquatable"が付いていないプロパティだけをフィルタリングする
        let propertiesToCompare = variableDecls.filter { decl in
            !decl.attributes.contains { attr in
                attr.as(AttributeSyntax.self)?.attributeName.trimmedDescription
                    == "SkipEquatable"
            }
        }.compactMap { $0.bindings.first?.pattern.trimmedDescription }

        // 3. プロパティを比較するコードを行ごとに生成
        let comparisons = propertiesToCompare.map { property in
            "lhs.\(property) == rhs.\(property)"
        }

        // 4. "==" メソッドを持つ extension を生成
        let equatableExtension = try ExtensionDeclSyntax(
            """
            extension \(type.trimmed): Equatable {
                public static func == (lhs: \(type.trimmed), rhs: \(type.trimmed)) -> Bool {
                    return \(raw: comparisons.joined(separator: " && "))
                }
            }
            """
        )

        return [equatableExtension]
    }
}

public struct SkipEquatableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 目印として利用するため、何もしない
        []
    }
}
