// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SwiftySensors",
    platforms: [
            .iOS(.v13),
        ],
    products: [
        .library(name: "SwiftySensors", targets: ["SwiftySensors"]),
    ],
    dependencies: [
        .package(url: "https://github.com/artman/Signals", from: Version(6, 1, 0))
    ],
    targets: [
        .target(name: "SwiftySensors", dependencies: ["Signals"])
    ]
)
