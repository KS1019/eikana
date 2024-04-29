import SwiftUI
import LaunchAtLogin

@main
struct eikanaApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @State var currentNumber: String = "1"

    @Environment(\.openWindow) var openWindow

    var body: some Scene {
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            Button("Open") {
                openWindow(id: "launch-at-login")
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }

        Window("Launch At Login", id: "launch-at-login") {
            Form {
                LaunchAtLogin.Toggle()
                    .toggleStyle(.switch)
            }
            .padding()
        }
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
