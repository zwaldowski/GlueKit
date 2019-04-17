// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "GlueKit",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .watchOS(.v3), .tvOS(.v10)
    ],
    products: [
        .library(name: "GlueKit", targets: ["GlueKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/zwaldowski/BTree", .branch("zwaldowski/swift-5.0"))
    ],
    targets: [
        .target(name: "GlueKit", dependencies: ["BTree"], path: "Sources"),
        .testTarget(name: "GlueKitTests", dependencies: ["GlueKit"], path: "Tests/GlueKitTests"),
        .testTarget(name: "PerformanceTests", dependencies: ["GlueKit"], path: "Tests/PerformanceTests")
    ],
    swiftLanguageVersions: [.v5]
)
