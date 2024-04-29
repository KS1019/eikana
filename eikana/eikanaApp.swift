import SwiftUI

@main
struct eikanaApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @State var currentNumber: String = "1"

    var body: some Scene {
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            Button("One") {
                currentNumber = "1"
            }
            Button("Two") {
                currentNumber = "2"
            }
            Button("Three") {
                currentNumber = "3"
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    let eisu: UInt16 = 102
    let kana: UInt16 = 104
    let rightCommandKey: UInt16 = 54
    let leftCommandKey: UInt16 = 55
    var flagsChangeMonitor: Any?
    var keyDownMonitor: Any?
    var lastKeycode: UInt16 = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        flagsChangeMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged, handler: flagsChanged(evt:))
        keyDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: keyDown(evt:))
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSEvent.removeMonitor(flagsChangeMonitor!)
    }

    private func flagsChanged(evt: NSEvent) -> Void {
        if !evt.modifierFlags.contains(.command) && lastKeycode == evt.keyCode {
            switch evt.keyCode {
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

        lastKeycode = evt.keyCode
    }

    private func keyDown(evt: NSEvent) -> Void {
        lastKeycode = evt.keyCode
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
