// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "TypeEraserGenerator",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "TypeEraserGenerator",
            targets: ["TypeEraserGenerator"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "602.0.0-latest"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-macro-testing.git",
            from: "0.0.0-latest"
        ),
        .package(
            url: "https://github.com/nicklockwood/SwiftFormat.git",
            from: "0.0.0-latest"
        ),
    ],
    targets: [
        .macro(
            name: "TypeEraserGeneratorMacros",
            dependencies: [
                "MultiModule",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftBasicFormat", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .target(
            name: "TypeEraserGenerator",
            dependencies: ["TypeEraserGeneratorMacros", "Helpers", "MultiModule"]
        ),

        .target(name: "Helpers"),

        .target(name: "MultiModule"),

        .testTarget(
            name: "TypeEraserGeneratorTests",
            dependencies: [
                "TypeEraserGenerator",
                "TypeEraserGeneratorMacros",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
