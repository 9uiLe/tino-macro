// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "tino-macro",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "TinoMacro",
            targets: ["TinoMacro"]
        ),
        .executable(
            name: "TinoMacroClient",
            targets: ["TinoMacroClient"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            exact: "601.0.1"
        )
    ],
    targets: [
        .macro(
            name: "TinoMacroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ]
        ),
        .target(name: "TinoMacro", dependencies: ["TinoMacroMacros"]),
        .executableTarget(name: "TinoMacroClient", dependencies: ["TinoMacro"]),
        .testTarget(
            name: "TinoMacroTests",
            dependencies: [
                "TinoMacroMacros",
                .product(
                    name: "SwiftSyntaxMacrosTestSupport",
                    package: "swift-syntax"
                ),
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
