import Foundation

func runMv(_ src: String, _ dest: String) throws {
    let mv = Process()
    mv.executableURL = URL(fileURLWithPath: "/bin/mv")
    mv.arguments = [src, dest]
    try mv.run()
    mv.waitUntilExit()
}

func runRm(_ target: String) throws {
    let rm = Process()
    rm.executableURL = URL(fileURLWithPath: "/bin/rm")
    rm.arguments = ["-r", target]
    try rm.run()
    rm.waitUntilExit()
}

try runRm("/Applications/eikana.app")
try runMv("Archive.xcarchive/Products/Applications/eikana.app", "/Applications")
