// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "NodeAApp",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/AGABOYI/Swift-Raft-Engine.git", from:"0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "NodeAApp",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "RaftSwiftPackage", package: "Swift-Raft-Engine")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "NodeAAppTests",
            dependencies: [
                .target(name: "NodeAApp"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
