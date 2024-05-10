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
    guard let url = URL(string: "/usr/bin/sh") else {
        preconditionFailure("xcrun could not be found")
    }
    print("======================")
    print("Started")
    print("URL: \(url)")
    xcrun.executableURL = url
    print("ee")
    xcrun.arguments = arguments

    try xcrun.run()
}

func runXcrun(_ arguments: String) throws {
    let arguments: [String] = arguments.components(separatedBy: " ")
    try runXcrun(arguments)
}

try runXcrun("-c xcrun xcodebuild -project ../eikana.xcodeproj -scheme eikana -configuration Release -archivePath Archive.xcarchive archive")
