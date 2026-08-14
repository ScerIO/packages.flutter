// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let flutterFramework: Target.Dependency = .product(
    name: "FlutterFramework",
    package: "FlutterFramework"
)

let package = Package(
    name: "pdfx",
    platforms: [
        .iOS("13.0"),
        .macOS("10.15")
    ],
    products: [
        .library(name: "pdfx", targets: ["pdfx"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        // Swift Package Manager does not support mixing Objective-C and Swift
        // sources in one target, so the generated Pigeon bridge is separate
        // from the Swift plugin implementation.
        .target(
            name: "pdfx_messages",
            dependencies: [flutterFramework],
            path: "Sources/pdfx/messages",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include/pdfx_messages")
            ]
        ),
        .target(
            name: "pdfx",
            dependencies: [
                flutterFramework,
                "pdfx_messages"
            ],
            path: "Sources/pdfx",
            exclude: ["messages"]
        )
    ]
)
