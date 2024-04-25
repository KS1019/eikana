import SwiftUI

@main
struct eikanaApp: App {
    @State var currentNumber: String = "1"
    let eisu: UInt16 = 102
    let kana: UInt16 = 104

    init() {
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged, handler: commandKey(evt:))
    }

    var body: some Scene {
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            Button("One") {
                currentNumber = "1"
            }
            .keyboardShortcut("1")
            Button("Two") {
                currentNumber = "2"
            }
            .keyboardShortcut("2")
            Button("Three") {
                currentNumber = "3"
            }
            .keyboardShortcut("3")
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
    }

    func commandKey(evt: NSEvent) -> Void {
        if evt.modifierFlags.contains(.command){
            print("commanded by \(evt.keyCode)")
            if evt.keyCode == 54 {
                // right command
                down(kana)
                up(kana)
            }

            if evt.keyCode == 55 {
                // left command
                down(eisu)
                up(eisu)
            }
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
