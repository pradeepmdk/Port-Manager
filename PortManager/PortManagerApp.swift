import SwiftUI
import AppKit

@main
struct PortManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var scanner = PortScanner()

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 App launching...")
        print("📦 Bundle ID: \(Bundle.main.bundleIdentifier ?? "nil")")

        // Temporarily disabled singleton check for debugging
        // Check if another instance is already running
        // let runningApps = NSWorkspace.shared.runningApplications
        // let otherInstances = runningApps.filter {
        //     $0.bundleIdentifier == Bundle.main.bundleIdentifier && $0 != NSRunningApplication.current
        // }
        //
        // if !otherInstances.isEmpty {
        //     print("⚠️ Another instance found, quitting")
        //     otherInstances.first?.activate(options: .activateIgnoringOtherApps)
        //     NSApp.terminate(nil)
        //     return
        // }

        print("✅ No other instance, creating status bar...")
        // Create status bar item with icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            print("✅ Status bar button created")

            // Create a custom icon image
            let image = NSImage(size: NSSize(width: 18, height: 18))
            image.lockFocus()

            // Draw a simple port/network icon
            let path = NSBezierPath()
            // Draw three horizontal lines (representing ports)
            NSColor.white.setStroke()
            path.lineWidth = 2

            path.move(to: NSPoint(x: 2, y: 4))
            path.line(to: NSPoint(x: 16, y: 4))

            path.move(to: NSPoint(x: 2, y: 9))
            path.line(to: NSPoint(x: 16, y: 9))

            path.move(to: NSPoint(x: 2, y: 14))
            path.line(to: NSPoint(x: 16, y: 14))

            path.stroke()
            image.unlockFocus()
            image.isTemplate = true

            button.image = image
            button.action = #selector(handleClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self

            print("✅ Icon created and assigned")
        } else {
            print("❌ Failed to create status bar button")
        }

        // Create popover with content view
        print("📦 Creating popover...")
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 900, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView(scanner: scanner))
        print("✅ Popover created")

        // Start scanning ports
        print("🔍 Starting initial port scan...")
        scanner.scanPorts()

        // Auto-refresh every 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.scanner.scanPorts()
        }

        print("🎉 App fully initialized!")
        print("👀 Look for ≡ icon in menu bar (top-right)")
    }

    @objc func handleClick() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            togglePopover()
        }
    }

    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    @objc func showMenu() {
        let menu = NSMenu()

        // Port count
        let portCount = scanner.ports.count
        let countItem = NSMenuItem(title: "\(portCount) Port(s) Active", action: nil, keyEquivalent: "")
        countItem.isEnabled = false
        menu.addItem(countItem)

        menu.addItem(NSMenuItem.separator())

        // Refresh
        menu.addItem(NSMenuItem(title: "Refresh Now", action: #selector(refreshPorts), keyEquivalent: "r"))

        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(NSMenuItem(title: "Quit Port Manager", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc func refreshPorts() {
        scanner.scanPorts()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
