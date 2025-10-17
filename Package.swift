// swift-tools-version:5.5
import PackageDescription
let package = Package(
    name: "CleanMac",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "cleanmac", targets: ["CleanMac"]),
        .library(name: "CleanMacCore", targets: ["CleanMacCore"]),
        .executable(name: "cleanmac-security", targets: ["CleanMacSecurity"])
    ],
    targets: [
        .executableTarget(name: "CleanMac", dependencies: ["CleanMacCore", "SecurityCore"], path: "Sources/CleanMac"),
        .target(name: "CleanMacCore", path: "Sources/CleanMacCore"),
        .executableTarget(name: "CleanMacSecurity", dependencies: ["SecurityCore"], path: "Sources/SecurityModule/CleanMacSecurity"),
        .target(name: "SecurityCore", path: "Sources/SecurityModule/SecurityCore"),
        .testTarget(name: "CleanMacTests", dependencies: ["CleanMac"])
    ]
)
