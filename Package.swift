// swift-tools-version:4.0
import PackageDescription
let package = Package(
    name: "JSON",
    products: [
        .library(name: "JSON", targets: ["JSON"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "JSON", dependencies: []),
        .testTarget(name: "JSONTests", dependencies: ["JSON"]),
    ]
)