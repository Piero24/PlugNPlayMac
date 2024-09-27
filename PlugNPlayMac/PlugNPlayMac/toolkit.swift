//
//  toolkit.swift
//  PlugNPlayMac
//
//  Created by Andrea Pietrobon on 21/09/24.
//

import Foundation


/// Determines whether the system is running on Apple Silicon.
///
/// This function checks the current system architecture to determine if it is using Apple Silicon (arm64).
///
/// - Returns: `true` if the system is Apple Silicon, otherwise `false`.
///
/// - Example:
///   ```
///   if isAppleSilicon() {
///       print("Running on Apple Silicon")
///   }
///   ```
///
/// - Note: Uses compile-time checks to identify the system architecture.
func isAppleSilicon() -> Bool {
    var isAppleSilicon: Bool = false
    #if arch(arm64)
        isAppleSilicon = true
    #endif
    return isAppleSilicon
}


/// Retrieves the current macOS version.
///
/// This function returns the current macOS version as a double, combining the major and minor versions (e.g., 14.3 becomes 14.03).
///
/// - Returns: The current macOS version as a `Double`.
///
/// - Example:
///   ```
///   let osVersion = getCurrentOS()
///   print("macOS Version: \(osVersion)")
///   ```
func getCurrentOS() -> Double {
    let majorVersion = Double(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)
    let minorVersion = Double(ProcessInfo.processInfo.operatingSystemVersion.minorVersion)
    
    return majorVersion + (minorVersion / 100.0)
}


/// Retrieves the system's idle time in seconds.
///
/// This function reads the system's idle time, which is the amount of time since the last user interaction (e.g., mouse or keyboard input).
/// It queries the `IOHIDSystem` for the idle time property and converts it from nanoseconds to seconds.
///
/// - Returns: The idle time in seconds, or `nil` if the idle time could not be retrieved.
///
/// - Example:
///   ```
///   if let idleTime = getIdleTimeInSeconds() {
///       print("System has been idle for \(idleTime) seconds.")
///   }
///   ```
func getIdleTimeInSeconds() -> Int? {
    // Define kHIDIdleTime if it's not found
    let kHIDIdleTime = "HIDIdleTime" as CFString
    
    // Create an IOHIDService for IOHIDSystem
    let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOHIDSystem"))
    // Check if the service is valid
    guard service != 0 else {
        printLog("E4", "The service isn't valid")
        return nil
    }
    // Get the idle time property
    var idleTime: AnyObject?
    let result = IORegistryEntryCreateCFProperty(service, kHIDIdleTime, kCFAllocatorDefault, 0)
    
    if let value = result?.takeRetainedValue() as? NSNumber {
        idleTime = value
    }

    // Release the service
    IOObjectRelease(service)
    
    // Convert idle time to seconds
    if let idleTimeValue = idleTime as? UInt64 {
        printLog("S4", "The time passed from the las user interaction are: \(Int(idleTimeValue / 1_000_000_000)) seconds")
        // Convert from nanoseconds to seconds
        return Int(idleTimeValue / 1_000_000_000)
    }
    printLog("E4", "Something went wrong when try to calculate the time from the last interaction of the user")
    return nil
}


/// Provides methods to start and stop the `caffeinate` process, which prevents the system from sleeping.
/// `man caffeinate` for more information.
struct NoSleep {
    
    /// Starts the `caffeinate` process to prevent the system from sleeping.
    ///
    /// This function runs the `caffeinate` command in the background, preventing the system from sleeping.
    ///
    /// - Returns: `true` if the `caffeinate` command was successfully started, otherwise `false`.
    ///
    /// - Example:
    ///   ```
    ///   if NoSleep.startCaffeinate() {
    ///       print("System will not sleep")
    ///   }
    ///   ```
    static func startCaffeinate() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "nohup caffeinate -u -i -d & wait 2>/dev/null &"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        
        do {
            try process.run()
            printLog("S4", "Start caffeinate successfully")
            return true
        } catch {
            printLog("E4", "Can't run caffeinate error: \(error)")
            return false
        }
    }
    
    
    /// Stops the `caffeinate` process to allow the system to sleep normally.
    ///
    /// This function runs the `pkill caffeinate` command to stop the background `caffeinate` process.
    ///
    /// - Returns: `true` if the `caffeinate` process was successfully stopped, otherwise `false`.
    ///
    /// - Example:
    ///   ```
    ///   if NoSleep.stopCaffeinate() {
    ///       print("System can now sleep")
    ///   }
    ///   ```
    static func stopCaffeinate() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "pkill caffeinate"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        
        do {
            try process.run()
            printLog("S4", "Stop caffeinate successfully")
            return true
        } catch {
            printLog("E4", "Can't stop caffeinate error: \(error)")
            return false
        }
    }
}
