import Foundation

precondition(CommandLine.arguments.count == 3)

let releaseConfigPath = "../Configs/Release.xcconfig"
guard let content = FileManager.default.contents(atPath: releaseConfigPath),
      let contentString = String(data: content, encoding: .utf8) else {
    fatalError()
}

guard let replaced = contentString
    .replacing(#/CI_MARKETING_VERSION/#, with: CommandLine.arguments[1])
    .replacing(#/CI_CURRENT_PROJECT_VERSION/#, with: CommandLine.arguments[2])
    .data(using: .utf8) else {
    fatalError()
}

try replaced.write(to: URL(fileURLWithPath: releaseConfigPath))
