//
//  apps.swift
//  PlugNPlayMac
//
//  Created by Andrea Pietrobon on 26/09/24.
//

import Foundation
import AppKit


/// Opens an application by its name in the background.
///
/// This function searches for the specified application in common directories like `/Applications`, `/Applications/Utilities`, and `~/Applications`.
/// If the application is found, it is launched in the background without being brought to the foreground.
/// The app's window will not appear, but the app will be running in the background.
///
/// - Parameter appName: The name of the application to open (e.g., "Google Chrome").
///
/// - Example:
///   ```
///   openAppByNameInBackground(appName: "Google Chrome")
///   ```
///
/// - Note: If the app is not found in the specified directories, an error message will be logged.
///
func openAppByNameInBackground(appName: String) {
    let workspace = NSWorkspace.shared
    let fileManager = FileManager.default

    // Common paths where applications are stored
    let appPaths = ["/Applications", "/Applications/Utilities", "~/Applications"]

    for path in appPaths {
        let appURL = URL(fileURLWithPath: "\(path)/\(appName).app")
        
        // Check if the app exists at this location
        if fileManager.fileExists(atPath: appURL.path) {
            let config = NSWorkspace.OpenConfiguration()
            config.activates = false  // Prevents the app from being brought to the foreground
            
            workspace.openApplication(at: appURL, configuration: config) { (app, error) in
                if let error = error {
                    printLog("E4", "Error launching \(appName): \(error)")
                } else {
                    printLog("S4", "\(appName) launched successfully in the background")
                }
            }
            return
        }
    }
    
    printLog("E4", "Application \(appName) not found")
}


/// Closes an application by its name.
///
/// This function looks for a running application that matches the provided name and sends it a terminate signal to close it.
/// If the application is found and running, it will be closed gracefully. Otherwise, an error message is logged.
///
/// - Parameter appName: The name of the application to close (e.g., "Google Chrome").
///
/// - Example:
///   ```
///   closeAppByName(appName: "Google Chrome")
///   ```
///
/// - Note: If the app is not running, a message will be logged indicating the app could not be found.
///
func closeAppByName(appName: String) {
    let workspace = NSWorkspace.shared
    
    // Get a list of running applications
    let runningApps = workspace.runningApplications
    
    // Find the app that matches the provided name
    if let app = runningApps.first(where: { $0.localizedName == appName }) {
        app.terminate()  // Send the terminate signal
        printLog("S4", "\(appName) has been closed")
    } else {
        printLog("E4", "Application \(appName) is not running")
    }
}
