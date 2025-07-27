// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "TinoMacro",
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
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "TinoMacroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "TinoMacro", dependencies: ["TinoMacroMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "TinoMacroClient", dependencies: ["TinoMacro"]),

        // A test target used to develop the macro implementation.
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
