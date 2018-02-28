// swift-tools-version:4.0
import PackageDescription
let package = Package(
    name: "JSON",
    products: [
        .library(name: "JSON", targets: ["JSON"]),
        .library(name: "JSONKit", targets: ["JSONKit", "JSON"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc")
    ],
    targets: [
        .target(name: "JSON", dependencies: []),
        .target(name: "JSONKit", dependencies: ["JSON", "Vapor"]),
        .testTarget(name: "JSONTests", dependencies: ["JSON", "JSONKit"]),
    ]
)
