//
//  main.swift
//  PlugNPlayMac
//
//  Created by Andrea Pietrobon on 21/09/24.
//
// This script automates tasks like keeping the Mac awake (using `caffeinate`),
// managing application states (like opening or closing certain apps based on Wi-Fi or display connections),
// and handling battery charge limits via a BCLM daemon.
//
// bash -c "nohup caffeinate -u -i -d &"          // Keeps the system awake indefinitely in the background.
// ps aux -o ppid | grep caffeinate               // Finds running caffeinate processes.
// launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist   // Loads a launch agent.
// launchctl unload /Library/LaunchAgents/com.launch.plug.and.play.mac.plist // Unloads a launch agent.
//
// Helpful resources:
// - https://fig.io                   // Terminal tool that enhances CLI experience.
// - https://ohmyz.sh                  // Framework for managing zsh configuration.
// - https://stackoverflow.com/questions/27379507/creating-and-writing-into-plist-with-terminal-or-bash-script  // Writing and creating plists.
//
//
// Log format used:
// "S" indicates a success message and "E" indicates an error.
// "X0-X1" Main, "X2" Network, "X3" Display, "X4" Toolkit, "X5" Bclm, "X6" Keychain

import Foundation
import Cocoa
// import Combine


_ = NSApplication.shared

// Initialize parameters and values for the script.
var inputParams = Params(
    displayNames: ["LG IPS FULLHD"],        // Target display names to look for.
    wifiNames: ["Vodafone-A45682606"],      // Target Wi-Fi networks to check for.
    appsToOpen: ["Elgato Stream Deck", "MonitorControl"],  // Apps to open when conditions are met.
    batteryValue: 80                        // Battery charge limit to enforce.
)

var val = Val()  // Initialize application state.

printLog("S0", "Current macOS version: \(osVersion)")
printLog("S0", "Start the PlugNPlayMac script")

while true {
    
    RunLoop.main.acceptInput(forMode: .default, before: .distantPast)
    
    // Get the current Wi-Fi network name.
    let networkName: String = getWiFiNetworkName(osVersion)
    // Check if the current Wi-Fi matches the target.
    let isWifiFound: Bool = wifiFound(inputParams.wifiNames, networkName)
    
    // Get a list of connected displays.
    let displayList: [String] = getDisplayNames()
    
    // Check if target display is connected.
    let isDisplayFound: Bool = displayFound(inputParams.displayNames, displayList)

    // Check if any connected displays are awake.
    let isSleep: Bool = !isAtLeasstOneDisplayAwake()

    // Get idle time (time since last user interaction).
    let idleTime = getIdleTimeInSeconds()
    // Current time in seconds.
    let currentTime = Int(Date().timeIntervalSince1970)
    // Calculate time since last user interaction.
    let timeDifference = currentTime - val.lastUpdateTime

    // If more than 10 minutes of inactivity, reset the firstTime flag to true.
    if !val.firstTime && timeDifference > 300 {
        val.firstTime = true
        printLog("S1", "More than 5 minutes have passed since the last check. Resetting firstTime to true")
    }
    
    // If the desired display and Wi-Fi are connected and system is not sleeping
    if isDisplayFound && isWifiFound {
        if !val.isRunning && !isSleep {
            // Prevent `caffeinate` if the user has been idle for more than 10 minutes
            if ((idleTime ?? 1) / 60) < 10 {
                // Stop previous caffeinate processes if any.
                var _ = NoSleep.stopCaffeinate()
                // Start caffeinate to keep the system awake.
                val.isCaffeinate = NoSleep.startCaffeinate()
                val.isRunning = true
            }

            // Open apps in the background when the conditions are met.
            for app in inputParams.appsToOpen {
                openAppByNameInBackground(appName: app)
            }
            val.areAppsOpen = true

            // Apply battery charge limit management (BCLM) if not already set.
            if !val.isBclm {
                let batteryResult: Int = setBclm(inputParams.batteryValue)

                // Set the BCLM flag if successful.
                if batteryResult == inputParams.batteryValue {
                    val.isBclm = true
                }
            }

        } else if val.isRunning && isSleep {
            // If system goes to sleep while apps are running, stop caffeinate.
            if val.isCaffeinate {
                val.isCaffeinate = !NoSleep.stopCaffeinate()
            }
        } else if val.isRunning && !isSleep {
            // If the system is awake and caffeinate is not running, restart caffeinate
            if !val.isCaffeinate {
                if ((idleTime ?? 1) / 60) < 10 {
                    var _ = NoSleep.stopCaffeinate()
                    val.isCaffeinate = NoSleep.startCaffeinate()
                }
            }
        }

    } else if !isDisplayFound {
        // If the target display is not found, reset the system state.
        if val.isRunning {
            // Retry the check if this is the first failure to find the display.
            if val.firstTime {
                printLog("S1", "First time the display is not found. Restart the check.")
                val.firstTime = false
                val.lastUpdateTime = Int(Date().timeIntervalSince1970)
                sleep(15)
                continue
            }

            // Stop the caffeinate process if it is running.
            val.isCaffeinate = !NoSleep.stopCaffeinate()
            val.isRunning = false

            // Close all apps that were opened.
            for app in inputParams.appsToOpen {
                closeAppByName(appName: app)
            }

            val.areAppsOpen = false

            // Reset the battery charge limit to 100% and unload the BCLM plist.
            if val.isBclm {
                var _ = setBclmUnpersist()
                removeFilePlistBclm(password: getPassword("PlugNPlayMac", account) ?? "", filePath: filePath)
                let batteryResult: Int = setBclm(100)

                if batteryResult == 100 {
                    val.isBclm = false
                }
            } else if isAppRunning(appName: alternativeBclm) {
                closeAppByName(appName: alternativeBclm)
            }
        }
    }
    sleep(60)
}
