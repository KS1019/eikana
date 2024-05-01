import SwiftUI
import LaunchAtLogin

@main
struct eikanaApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @Environment(\.openWindow) var openWindow

    var body: some Scene {
        MenuBarExtra("", systemImage: "command") {
            Button("設定") {
                openWindow(id: "settings")
            }
            Divider()
            Button("再起動") {
                let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
                let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
                let task = Process()
                task.launchPath = "/usr/bin/open"
                task.arguments = [path]
                try! task.run()
                NSApplication.shared.terminate(self)
            }
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }

        Window("設定", id: "settings") {
            Form {
                Section("設定") { 
                    HStack {
                        LaunchAtLogin.Toggle("ログイン時に起動")
                            .toggleStyle(.switch)
                    }

                    HStack {
                        Text("Ver 0.0.1")
                    }
                }
            }
            .formStyle(.grouped)
            .padding()
            .toolbarBackground(Color.clear)
            .frame(width: 280, height: 200, alignment: .center)
        }
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject, NSWindowDelegate {
    let eisu: UInt16 = 102
    let kana: UInt16 = 104
    let rightCommandKey: UInt16 = 54
    let leftCommandKey: UInt16 = 55
    var flagsChangeMonitor: Any?
    var lastKeycode: UInt16 = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        flagsChangeMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown], handler: handle(event:))
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSEvent.removeMonitor(flagsChangeMonitor!)
    }

    private func handle(event: NSEvent) -> Void {
        precondition([.flagsChanged, .keyDown].contains(event.type))

        if event.type == .flagsChanged {
            if !event.modifierFlags.contains(.command) && lastKeycode == event.keyCode {
                switch event.keyCode {
                    case leftCommandKey:
                        down(eisu)
                        up(eisu)
                    case rightCommandKey:
                        down(kana)
                        up(kana)
                    default:
                        break
                }
            }
        } else {
            lastKeycode = event.keyCode
        }
    }

    func down(_ key: UInt16) {
        post(key: key, keyDown: true)
    }

    func up(_ key: UInt16) {
        post(key: key, keyDown: false)
    }

    func post(key: UInt16, keyDown: Bool) {
        let keyDownEvent = CGEvent(keyboardEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState), virtualKey: key, keyDown: keyDown)!
        keyDownEvent.flags = CGEventFlags(rawValue: 0)
        keyDownEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
}
