import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EquatableMacro: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        // 構造体のプロパティを全て取得する
        let members = declaration.memberBlock.members
        let variableDecls = members.compactMap {
            $0.decl.as(VariableDeclSyntax.self)
        }

        // この型が View プロトコルに準拠しているかを確認
        let inheritedTypes = declaration.inheritanceClause?.inheritedTypes ?? []
        let identifierTypes = inheritedTypes.compactMap {
            $0.type.as(IdentifierTypeSyntax.self)
        }
        let containsView: Bool = identifierTypes.contains {
            $0.name.text == "View"
        }

        // "@SkipEquatable"が付いていない、かつ"body"プロパティがViewに準拠しない型の場合はフィルタリングする
        let propertiesToCompare = variableDecls.filter { decl in
            let isSkippedByAttribute = decl.attributes.contains { attribute in
                // 属性名が "SkipEquatable" かどうかをチェック
                attribute.as(AttributeSyntax.self)?.attributeName
                    .trimmedDescription == "SkipEquatable"
            }

            // @SkipEquatable が付いている場合は比較から除外
            if isSkippedByAttribute {
                return false
            }

            // プロパティ名が取得できない場合は除外
            guard
                let propertyName = decl.bindings.first?.pattern
                    .trimmedDescription
            else {
                return false
            }

            // "body" は View に準拠している場合のみ比較しない
            if propertyName == "body" && containsView {
                return false
            }

            // その他の場合は比較対象に含める
            return true
        }.compactMap { $0.bindings.first?.pattern.trimmedDescription }

        // 4. プロパティを比較するコードを行ごとに生成
        let comparisons: String
        if propertiesToCompare.isEmpty {
            // 比較対象のプロパティが一つもない場合は `true` を返す
            comparisons = "true"
        } else {
            comparisons = propertiesToCompare.map { property in
                "lhs.\(property) == rhs.\(property)"
            }.joined(separator: " && ")
        }

        // 5. "==" メソッドを持つ extension を生成
        let equatableExtension = try ExtensionDeclSyntax(
            """

            extension \(type.trimmed): @MainActor Equatable {
                public static func == (lhs: \(type.trimmed), rhs: \(type.trimmed)) -> Bool {
                    return \(raw: comparisons)
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
