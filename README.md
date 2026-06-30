## Android SDK Installer 

![Platform: Windows](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)

A PowerShell script to automate the installation of the Android SDK (CLI only) on Windows 10/11. Configured specifically to meet the requirements of the **Morphe** patching and modification ecosystem.

This script automatically downloads, extracts, configures Environment Variables, and installs the necessary tools without the need to install the heavy Android Studio IDE.

## 🚀 Features
* Dynamically downloads the latest official Android Command-line Tools directly from Google.
* Automatically sets up `ANDROID_HOME` and appends the required directories to your Windows `PATH`.
* Bypasses manual prompts by auto-accepting all Android SDK licenses.
* Extracts ZIP files using the native `.NET` module for better performance and efficiency.
* Installs the essential components required for application patching right out of the box.

## 📦 Installed Components
* `cmdline-tools` (contains `sdkmanager`)
* `platform-tools` (contains `adb`)
* `build-tools 34.0.0` (contains `aapt2`, `apksigner`, `zipalign`, and `d8`)

## ⚠️ Prerequisites
Before running this script, ensure your system meets the following requirements:
* **Windows 10 / 11**
* **JDK 25** (An absolute requirement for the Morphe ecosystem. The script includes a version detection check and will automatically exit if JDK 25 is not found).

## 🛠️ Usage
1. Download or clone this repository, and locate the `Install-AndroidSDK.ps1` file.
2. Open **PowerShell**.
3. (Optional) If your system blocks the execution of third-party scripts, run this command first to bypass the restriction temporarily:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```
   
4. Navigate to the directory where you saved the script, then run it:

   ```powershell
   .\Android-SDK-Installer.ps1
   ```
   
5. Wait for the installation to finish. Once completed, close your current PowerShell window and open a new one so the system can load the updated Environment Variables.
6. Verify the installation by typing:

   ```powershell
   d8 --version
   ```
   
## 📄 License

This project is created by **chihafuyu** and is open-sourced under the **[MIT License](https://opensource.org/licenses/mit)**.

**Copyright (c) 2026 chihafuyu**

Basically: you are free to use, modify, and distribute this software for any purpose, as long as you keep the original copyright notice above. It is provided _"as is"_, without warranty of any kind. Use it at your own risk!