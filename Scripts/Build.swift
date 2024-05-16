import Foundation

let configuration =
    switch (CommandLine.arguments.first ?? "RELEASE").uppercased() {
    case "RELEASE":
        "RELEASE"
    case "DEBUG":
        "DEBUG"
    default:
        "RELEASE"
    }

func runXcrun(_ arguments: [String]) throws {
    let xcrun = Process()
    xcrun.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    xcrun.arguments = arguments
    try xcrun.run()
    xcrun.waitUntilExit()
}

func runXcrun(_ arguments: String) throws {
    let arguments: [String] = arguments.components(separatedBy: " ")
    try runXcrun(arguments)
}

try runXcrun("xcodebuild -resolvePackageDependencies -project ../eikana.xcodeproj -scheme eikana -configuration \(configuration) -archivePath Archive.xcarchive archive")
