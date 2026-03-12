// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Anyo",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "Anyo",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "Anyo"
        )
    ]
)
