// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "KeystrokeVisualizer",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "KeystrokeVisualizer",
            targets: ["KeystrokeVisualizer"]
        )
    ],
    targets: [
        .executableTarget(
            name: "KeystrokeVisualizer",
            path: ".",
            exclude: ["Makefile", "Info.plist", "Package.swift"]
        )
    ]
)