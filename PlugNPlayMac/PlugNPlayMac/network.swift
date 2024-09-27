//
//  network.swift
//  PlugNPlayMac
//
//  Created by Andrea Pietrobon on 21/09/24.
//

import AppKit


/// Retrieves the name of the Wi-Fi interface.
///
/// This function executes a shell command to identify the Wi-Fi hardware port on the system
/// and returns the corresponding interface name, such as "en0".
///
/// - Returns: The Wi-Fi interface name as a string if found, or `nil` if an error occurs or no Wi-Fi interface is found.
///
/// - Example:
///   ```
///   let wifiInterface = getWiFiInterface()
///   print("Wi-Fi Interface: \(wifiInterface ?? "Not found")")
///   ```
///
/// - Note: The function uses the `networksetup` command to list hardware ports and `awk` to filter the result.
func getWiFiInterface() -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = ["-c", "networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $NF}'"]

    let pipe = Pipe()
    process.standardOutput = pipe

    do {
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !output.isEmpty {
            return output
        }
    } catch {
        printLog("E2", "Error running process: \(error)")
    }

    return nil
}


/// Retrieves the name of the currently connected Wi-Fi network.
///
/// This function checks the macOS version to determine the appropriate command to execute:
/// - For macOS versions >= 15.0, it uses `system_profiler` to get the current Wi-Fi network.
/// - For earlier versions, it retrieves the Wi-Fi interface and runs `networksetup` to get the current network name.
///
/// - Parameter osVersion: The current macOS version as a `Double`.
/// - Returns: The name of the current Wi-Fi network or an empty string if no network is detected.
///
/// - Example:
///   ```
///   let wifiName = getWiFiNetworkName(14.0)
///   print("Connected to Wi-Fi network: \(wifiName)")
///   ```
///
/// - Note: The function calls `getWiFiInterface()` to get the correct Wi-Fi interface for earlier macOS versions.
///
/// - See Also: `getWiFiInterface()`
func getWiFiNetworkName(_ osVersion: Double) -> String {
    
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    
    if osVersion >= 15.0 {
        process.arguments = ["-c", "system_profiler SPAirPortDataType | awk '/Current Network/ {getline;$1=$1;print $0 | \"tr -d \':\'\";exit}'"]
    } else {
        let wifiinterface = getWiFiInterface()
        process.arguments = ["-c", "networksetup -getairportnetwork \(wifiinterface ?? "en0") | awk -F ': ' '/Current Wi-Fi Network/{print $2}'"]
    }

    let pipe = Pipe()
    process.standardOutput = pipe

    do {
        try process.run()
    } catch {
        printLog("E2", "Error executing process. No wifi found")
        return ""
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    
    let outputResult = output ?? "No Wi-Fi network detected"
    printLog("S2", "Connected to: \(outputResult)")

    return output ?? ""
}


/// Checks if a specific Wi-Fi network is in the list of known networks.
///
/// This function checks if the `currentWifi` is present in the provided `wifiNames` list.
///
/// - Parameters:
///   - wifiNames: An array of Wi-Fi network names.
///   - currentWifi: The name of the current Wi-Fi network.
/// - Returns: `true` if the current Wi-Fi network is found in the `wifiNames` list, otherwise `false`.
///
/// - Example:
///   ```
///   let knownWifiNetworks = ["Home Wi-Fi", "Office Wi-Fi"]
///   let currentNetwork = "Home Wi-Fi"
///   let isKnown = wifiFound(knownWifiNetworks, currentNetwork)  // returns true
///   ```
func wifiFound(_ wifiNames: [String], _ currentWifi: String) -> Bool {
    if wifiNames.contains(currentWifi) {
        return true
    }
    return false
}
