import LaunchAtLogin
import SwiftUI
@preconcurrency import ApplicationServices.HIServices.AXUIElement

@main
struct EikanaApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @AppStorage("isDoubleDownEnabled") var isDoubleDownEnabled: Bool = false

    var body: some Scene {
        menuBarItem
        settingsWindow
        licensesWindow
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject, NSWindowDelegate {
    private let eisu: UInt16 = 102
    private let kana: UInt16 = 104
    private let rightCommandKey: UInt16 = 54
    private let leftCommandKey: UInt16 = 55
    private var flagsChangeMonitor: Any?
    private var lastKeycode: UInt16 = 0

    private var pushedCommandKeys: [(String, Date)] = []

    @Published public var isProcessTrusted: Bool = false
    @AppStorage("isDoubleDownEnabled") var isDoubleDownEnabled: Bool = false

    func applicationDidFinishLaunching(_: Notification) {
        flagsChangeMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown], handler: handle(event:))
        updateAXTrustedStatus()
    }

    func applicationWillTerminate(_: Notification) {
        NSEvent.removeMonitor(flagsChangeMonitor!)
    }

    private func handle(event: NSEvent) {
        precondition([.flagsChanged, .keyDown].contains(event.type))

        if event.type == .flagsChanged
            && !event.modifierFlags.contains(.command)
            && lastKeycode == event.keyCode {
            if isDoubleDownEnabled {
                switch event.keyCode {
                    case leftCommandKey:
                        pushedCommandKeys.append(("leftCommandKey", Date()))
                    case rightCommandKey:
                        pushedCommandKeys.append(("rightCommandKey", Date()))
                    default:
                        break
                }

                if pushedCommandKeys.count > 1 {
                    let lastPushedKey = pushedCommandKeys.removeLast()
                    let prevToLastKey = pushedCommandKeys.removeLast()

                    if lastPushedKey.0 == prevToLastKey.0 &&
                        prevToLastKey.1.is3InSecondsRange(with: lastPushedKey.1) {
                        if lastPushedKey.0 == "leftCommandKey" {
                            down(eisu)
                            up(eisu)
                        }

                        if lastPushedKey.0 == "rightCommandKey" {
                            down(kana)
                            up(kana)
                        }
                    } else {
                        pushedCommandKeys.append(lastPushedKey)
                    }
                }
            } else {
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

    private func down(_ key: UInt16) {
        post(key: key, keyDown: true)
    }

    private func up(_ key: UInt16) {
        post(key: key, keyDown: false)
    }

    private func post(key: UInt16, keyDown: Bool) {
        let keyDownEvent = CGEvent(keyboardEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState), virtualKey: key, keyDown: keyDown)!
        keyDownEvent.flags = CGEventFlags(rawValue: 0)
        keyDownEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }

    private func updateAXTrustedStatus() {
#if DEBUG
        isProcessTrusted = true
#else
        Task {
            try await Task.sleep(for: .seconds(1))
            self.isProcessTrusted = AXIsProcessTrusted()
            self.updateAXTrustedStatus()
        }
#endif
    }
}

struct MennuButton: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @Environment(\.openWindow) var openWindow

    var body: some View {
        Group {
            Button(action: {
                AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
            }, label: {
                Text("\(Image(systemName: "circle.fill"))").foregroundStyle(appDelegate.isProcessTrusted ? .green : .red) + Text("アクセシビリティ")
            })
            .disabled(appDelegate.isProcessTrusted)
            Button("設定") {
                openWindow(id: "settings")
                NSApplication.shared.unhide(self)
                if let wnd = NSApplication.shared.windows.first {
                    wnd.makeKeyAndOrderFront(self)
                    wnd.setIsVisible(true)
                }
            }
            .disabled(!appDelegate.isProcessTrusted)
            Divider()
            Button("再起動") {
                let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
                let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
                task.arguments = [path]
                try! task.run()
                NSApplication.shared.terminate(self)
            }
            .disabled(!appDelegate.isProcessTrusted)
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

extension EikanaApp {
    var menuBarItem: some Scene {
        MenuBarExtra("", systemImage: "command") {
            MennuButton()
                .environmentObject(appDelegate)
        }
    }

    var settingsWindow: some Scene {
        @Environment(\.openWindow) var openWindow

        return Window("設定", id: "settings") {
            Form {
                Section("設定") {
                    HStack {
                        LaunchAtLogin.Toggle("ログイン時に起動")
                            .toggleStyle(.switch)
                    }
                    HStack {
                        Toggle("二回押しで切り替える", isOn: $isDoubleDownEnabled)
                            .toggleStyle(.switch)
                    }
                    HStack {
                        Text("Ver ") + Text((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?.?.?")
                    }
                    HStack {
                        Link("Webサイト", destination: URL(string: "https://github.com/KS1019/eikana")!)
                    }
                    HStack {
                        Button("ライセンス") {
                            openWindow(id: "licenses")
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .frame(width: 250, height: 250, alignment: .center)
            .toolbarBackground(Color.clear)
            .scrollDisabled(true)
        }
        .windowResizability(.contentSize)
    }

    var licensesWindow: some Scene {
        Window("ライセンス", id: "licenses") {
            Form {
                Section("LaunchAtLogin-Modern") {
                    Text("""
                    MIT License

                    Copyright (c) Sindre Sorhus <sindresorhus@gmail.com> (https://sindresorhus.com)

                    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

                    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

                    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                    """)
                }
            }
            .formStyle(.grouped)
            .padding()
            .toolbarBackground(Color.clear)
        }
    }
}

extension Date {
    func is3InSecondsRange(with date: Date) -> Bool {
        self.addingTimeInterval(3) >= date
    }
}
