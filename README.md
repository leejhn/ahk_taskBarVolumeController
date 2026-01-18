# Taskbar Volume Controller

A simple and efficient AutoHotkey v2.0 script that allows you to control system volume by scrolling your mouse wheel over the Windows taskbar.

## 🚀 Features

- **Intuitive Control**: Scroll up to increase volume, scroll down to decrease.
- **Taskbar Only**: Volume changes only trigger when your mouse is over the taskbar, preventing accidental adjustments.
- **Multi-Monitor Support**: Works seamlessly across multiple monitors and their respective taskbars.
- **Smart Detection**: Automatically updates taskbar positions when display settings change (e.g., connecting a monitor).
- **Lightweight**: Minimal CPU and memory footprint.

## 🛠️ Prerequisites

- [AutoHotkey v2.0+](https://www.autohotkey.com/) installed on your Windows system.

## 📥 Installation

1. Download the `controlVolumeByMouse.ahk` file.
2. Double-click the file to run it with AutoHotkey.
3. (Optional) Move the file to your [Startup](https://support.microsoft.com/en-us/windows/add-an-app-to-run-automatically-at-startup-in-windows-10-150da165-dcd9-7230-517b-cf3c11ad0307) folder to have it run automatically when Windows starts.

## ⌨️ Usage

- **Hover & Scroll**: Move your mouse cursor anywhere on the Windows taskbar and scroll the mouse wheel.
- **Manual Refresh (F12)**: If you change taskbar settings and it's not detected, press `F12` to manually refresh taskbar positions.

## ⚙️ How it works

The script identifies the coordinates of all active taskbars (including secondary ones) and listens for mouse wheel events only when the cursor is within those regions. It uses Windows messages (`WM_DISPLAYCHANGE`) to detect monitor changes and keep taskbar positions up to date.

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).



