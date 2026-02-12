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
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .target(
            name: "TypeEraserGenerator",
            dependencies: ["TypeEraserGeneratorMacros", "Helpers"]
        ),

        .target(name: "Helpers"),

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
