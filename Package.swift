// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FilePath.swift",
    platforms: [.macOS(.v15), .iOS(.v17), .tvOS(.v17), .watchOS(.v10)],
    products: [
        .library(
            name: "FilePath",
            targets: ["FilePath"]
        ),
    ],
    targets: [
        .target(name: "FilePath"),
        .testTarget(
            name: "FilePathTests",
            dependencies: ["FilePath"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension SwiftSetting {
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")                                    // SE-0335, Swift 5.6,  SwiftPM 5.8+
    static let internalImportsByDefault: Self = .enableUpcomingFeature("InternalImportsByDefault")                // SE-0409, Swift 6.0,  SwiftPM 6.0+
    static let memberImportVisibility: Self = .enableUpcomingFeature("MemberImportVisibility")                    // SE-0444, Swift 6.1,  SwiftPM 6.1+
    static let inferIsolatedConformances: Self = .enableUpcomingFeature("InferIsolatedConformances")              // SE-0470, Swift 6.2,  SwiftPM 6.2+
    static let nonisolatedNonsendingByDefault: Self = .enableUpcomingFeature("NonisolatedNonsendingByDefault")    // SE-0461, Swift 6.2,  SwiftPM 6.2+
    static let immutableWeakCaptures: Self = .enableUpcomingFeature("ImmutableWeakCaptures")                      // SE-0481, Swift 6.2,  SwiftPM 6.2+
}

package.targets
    .filter { ![.system, .binary, .plugin].contains($0.type) }
    .forEach { 
        $0.swiftSettings = [
            .existentialAny,
            .internalImportsByDefault,
            .memberImportVisibility,
            .inferIsolatedConformances,
            .nonisolatedNonsendingByDefault,
            .immutableWeakCaptures,
            .defaultIsolation($0.isTest ? nil : MainActor.self)
        ]
    }
