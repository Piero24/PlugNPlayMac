//
//  display.swift
//  PlugNPlayMac
//
//  Created by Andrea Pietrobon on 21/09/24.
//

import Foundation
import AppKit
import CoreGraphics

func getOnlineDisplays() -> [UInt32] {
    // https://developer.apple.com/documentation/coregraphics/1455409-cgdisplayserialnumber
    var displayIDs: [UInt32] = []
    let maxDisplays: UInt32 = 20
    var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
    var displayCount: UInt32 = 0
    
    let error = CGGetOnlineDisplayList(maxDisplays, &onlineDisplays, &displayCount)
    
    if error == .success {
        printLog("S3", "Number of online displays: \(displayCount)")
        
        for i in 0..<displayCount {
            displayIDs.append(onlineDisplays[Int(i)])
            print(onlineDisplays[Int(i)])
        }
        return displayIDs
    } else {
        printLog("S3", "Error retrieving online displays: \(error)")
    }
    return displayIDs
}


/// Retrieves the names of all connected displays.
///
/// This function collects the localized names of all connected displays on the system
/// and returns them as an array of strings.
///
/// - Returns: An array of display names as strings.
func getDisplayNames() -> [String] {
    var names = [String]()
    guard !NSScreen.screens.isEmpty else {
        printLog("S3", "No displays are connected.")
        return names
    }
    
    NSScreen.screens.forEach {
        names.append($0.localizedName)
    }
    
    printLog("S3", "Connected to the following displays: \(names)")
    return names
}

/// Checks if any of the provided display names are found in the specified list of display names.
///
/// This function takes two arrays: one containing the names of currently connected displays and
/// another containing a list of display names to search for. It checks if any of the display
/// names in `displayNames` are present in `displayList`.
///
/// - Parameters:
///   - displayNames: An array of display names to search.
///   - displayList: An array of display names to search against.
/// - Returns: `true` if at least one display name in `displayNames` is found in `displayList`, otherwise `false`.
///
/// - Example:
///   ```
///   let displayNames = ["LG IPS FULLHD", "Built-in Retina Display"]
///   let listToSearch = ["LG IPS FULLHD"]
///   displayFound(displayNames, listToSearch)  // returns true
///   ```
func displayFound(_ displayNames: [String], _ displayList: [String]) -> Bool {
    for display in displayNames {
        if displayList.contains(display) {
            return true
        }
    }
    return false
}


/// Determines if a specific display is currently awake.
///
/// This function checks whether a display, identified by its `displayID`, is currently awake or asleep.
///
/// - Parameter displayID: The ID of the display to check.
/// - Returns: `true` if the display is awake, `false` if it is asleep.
///
/// - See Also: `CGDirectDisplayID`, `CGDisplayIsAsleep()`
func isDisplayAwake(displayID: CGDirectDisplayID) -> Bool {
    return CGDisplayIsAsleep(displayID) == 0
}


/// Checks if at least one connected display is awake.
///
/// This function retrieves the list of active displays connected to the system and determines
/// if any of them are currently awake.
///
/// - Returns: `true` if at least one display is awake, otherwise `false`.
///
/// - Example:
///   ```
///   if isAtLeasstOneDisplayAwake() {
///       print("At least one display is awake.")
///   } else {
///       print("All displays are asleep.")
///   }
///   ```
///
/// - Note: This function uses `CGGetActiveDisplayList()` to get the list of displays and
///   `isDisplayAwake(displayID:)` to check their awake status.
///
/// - See Also: `CGGetActiveDisplayList()`
func isAtLeasstOneDisplayAwake() -> Bool {
    var displayCount: UInt32 = 0
    CGGetActiveDisplayList(0, nil, &displayCount)

    if displayCount > 0 {
        var activeDisplays = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
        CGGetActiveDisplayList(displayCount, &activeDisplays, &displayCount)
        
        for displayID in activeDisplays {
            // print("Display ID: \(displayID)")
            if isDisplayAwake(displayID: displayID) {
                printLog("S3", "There is a display awake")
                return true
            }
        }
    }
    printLog("S3", "No display awake found")
    return false
}
