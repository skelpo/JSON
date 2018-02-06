// swift-tools-version:4.0
import PackageDescription
let package = Package(
    name: "JSON",
    products: [
        .library(name: "JSON", targets: ["JSON"]),
        .library(name: "JSONKit", targets: ["JSONKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "JSON", dependencies: []),
        .target(name: "JSONKit", dependencies: ["JSON"]),
        .testTarget(name: "JSONTests", dependencies: ["JSON", "JSONKit"]),
    ]
)
