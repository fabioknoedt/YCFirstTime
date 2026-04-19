// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "YCFirstTime",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "YCFirstTime", targets: ["YCFirstTime"]),
    ],
    targets: [
        .target(name: "YCFirstTime"),
        .testTarget(
            name: "YCFirstTimeTests",
            dependencies: ["YCFirstTime"]
        ),
    ]
)
