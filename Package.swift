// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "TJSceneDelegate",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "TJSceneDelegate",
            targets: ["TJSceneDelegate"]
        ),
    ],
    targets: [
        .target(
            name: "TJSceneDelegate",
            publicHeadersPath: "include"
        ),
    ]
)