// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IntervalTrainerCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "IntervalTrainerCore", targets: ["IntervalTrainerCore"])
    ],
    targets: [
        .target(name: "IntervalTrainerCore"),
        .testTarget(name: "IntervalTrainerCoreTests", dependencies: ["IntervalTrainerCore"])
    ]
)
