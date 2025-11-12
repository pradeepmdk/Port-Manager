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

            // Try to load the custom AppIcon.icns
            if let iconPath = Bundle.main.path(forResource: "AppIcon", ofType: "icns"),
               let iconImage = NSImage(contentsOfFile: iconPath) {
                // Use the beautiful dock icon in menu bar
                let resizedIcon = NSImage(size: NSSize(width: 18, height: 18))
                resizedIcon.lockFocus()
                iconImage.draw(in: NSRect(x: 0, y: 0, width: 18, height: 18),
                              from: NSRect(x: 0, y: 0, width: iconImage.size.width, height: iconImage.size.height),
                              operation: .copy,
                              fraction: 1.0)
                resizedIcon.unlockFocus()
                resizedIcon.isTemplate = false  // Keep colors, don't make it monochrome

                button.image = resizedIcon
                print("✅ Using custom AppIcon.icns for menu bar")
            } else {
                // Fallback: Create a simple icon
                let image = NSImage(size: NSSize(width: 18, height: 18))
                image.lockFocus()

                // Draw three horizontal lines (representing ports)
                NSColor.white.setStroke()
                let path = NSBezierPath()
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
                print("⚠️ Using fallback icon (AppIcon.icns not found)")
            }

            button.action = #selector(handleClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self

            print("✅ Icon assigned to menu bar")
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
