# Port Manager v1.0.0

## 🎉 Initial Release

Port Manager is a native macOS menu bar utility for monitoring and managing network ports on your Mac.

## ✨ Features

- **📊 Port Monitoring**: Real-time view of all active TCP and UDP ports
- **🔍 Process Details**: See which processes are using which ports
- **🎯 Quick Actions**: Kill processes directly from the menu bar
- **🔄 Auto-Refresh**: Stay updated with the latest port information
- **🎨 Native Interface**: Clean SwiftUI interface that fits right into macOS
- **⚡ Menu Bar Integration**: Quick access without cluttering your dock

## 📥 Installation

### Quick Install (Recommended)

1. Download `PortManager-v1.0.0.dmg` from the Assets section below
2. Open the DMG file
3. Drag **PortManager.app** to the **Applications** folder
4. Launch Port Manager from Applications
5. The app will appear in your menu bar

### Build from Source

```bash
git clone https://github.com/pradeepmdk/Port-Manager-Mac.git
cd Port-Manager-Mac
xcodebuild -project PortManager.xcodeproj -scheme PortManager -configuration Release build
```

## 🎮 Usage

1. Click the Port Manager icon in your menu bar
2. Browse all active ports and their processes
3. Use the search to filter specific ports or processes
4. Click "Kill Process" to terminate any unwanted process
5. Click "Refresh" to update the port list

## 📋 Requirements

- macOS 13.0 (Ventura) or later
- ARM64 (Apple Silicon) or x86_64 (Intel) Mac

## ⚠️ Permissions

The app requires permission to:
- Execute system commands (`lsof` for port scanning)
- Terminate processes (with user confirmation)

Some system processes may require administrator privileges to terminate.

## 🐛 Known Issues

None reported yet! Please open an issue if you encounter any problems.

## 🙏 Acknowledgments

Built with Swift and SwiftUI for macOS.

---

**Full Changelog**: https://github.com/pradeepmdk/Port-Manager-Mac/commits/v1.0.0
