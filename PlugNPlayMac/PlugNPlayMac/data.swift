//
//  data.swift
//  PlugNPlayMac
//
//  Created by Andrea Pietrobon on 25/09/24.
//


/// Stores various configuration parameters for the application.
///
/// This struct contains values that represent display names, Wi-Fi network names,
/// apps that need to be opened, and a battery value. The values are initialized
/// during the creation of the struct and remain constant except for `batteryValue`,
/// which can be modified after initialization.
///
/// - Properties:
///   - displayNames: An array of strings representing the names of the external displays.
///   - wifiNames: An array of strings representing the Wi-Fi network names to look for.
///   - appsToOpen: An array of strings with the names of applications that should be opened.
///   - batteryValue: An integer representing the battery limit setting, which can be changed after initialization.
///
/// - Example:
///   ```
///   let params = Params(displayNames: ["LG Monitor"], wifiNames: ["HomeWiFi"], appsToOpen: ["Google Chrome"], batteryValue: 80)
///   ```
///
struct Params {
    let displayNames: [String]
    let wifiNames: [String]
    let appsToOpen: [String]
    var batteryValue: Int
}


/// Manages the current application state.
///
/// This struct keeps track of various states that the application is in, including whether it’s the
/// first time it’s being run, if it's currently running, whether the `caffeinate` process is active,
/// whether the necessary apps are open, and if the battery limit management (`bclm`) feature is enabled.
///
/// - Properties:
///   - firstTime: A boolean that indicates if this is the first time the app is running. Defaults to `true`.
///   - isRunning: A boolean that shows whether the app is currently running. Defaults to `false`.
///   - isCaffeinate: A boolean representing whether the `caffeinate` process is currently active. Defaults to `false`.
///   - areAppsOpen: A boolean indicating if the apps listed in `appsToOpen` are currently open. Defaults to `false`.
///   - isBclm: A boolean indicating if the battery limit management feature (`bclm`) is enabled. Defaults to `false`.
///
/// - Example:
///   ```
///   var val = Val()
///   val.isRunning = true
///   ```
///
struct Val {
    var firstTime : Bool = true
    var isRunning : Bool = false
    var isCaffeinate: Bool = false
    var areAppsOpen : Bool = false
    var isBclm : Bool = false
    var lastUpdateTime : Int = 0
}


/// The main path where the PlugNPlayMac files are located.
///
/// This string holds the file path to the directory where the core application files for PlugNPlayMac are stored.
///
/// - Example:
///   ```
///   let path = mainPath  // "/usr/local/bin/PlugNPlayMac*"
///   ```
///
let mainPath : String = "/usr/local/bin/PlugNPlayMac*"


/// The file path to the `com.zackelia.bclm.plist` file used for battery limit management.
///
/// This constant holds the path to the launch daemon that controls the battery charge limit (BCLM).
/// It is used in various system commands for modifying or reading the BCLM settings.
///
/// - Example:
///   ```
///   let path = filePath  // "/Library/LaunchDaemons/com.zackelia.bclm.plist"
///   ```
///
let filePath = "/Library/LaunchDaemons/com.zackelia.bclm.plist"


/// The account username for the current user.
///
/// This constant stores the name of the currently logged-in user, which is fetched using the `getUserName()` function.
///
/// - Example:
///   ```
///   let user = account  // "username"
///   ```
///
let account: String = getUserName()


/// The password associated with the PlugNPlayMac application for the current user.
///
/// This constant stores the user's password, fetched using the `getPassword()` function.
/// If the password cannot be retrieved, an empty string is used instead.
///
/// - Example:
///   ```
///   let password = pswd  // "myPassword"
///   ```
///
let pswd : String = getPassword("PlugNPlayMac", account) ?? ""


/// The current macOS version as a double value.
///
/// This constant stores the macOS version (major and minor) in a format like `10.15` or `12.3`,
/// fetched using the `getCurrentOS()` function.
///
/// - Example:
///   ```
///   let osVersion = getCurrentOS()  // e.g. 12.3
///   ```
///
let osVersion : Double = getCurrentOS()

let alternativeBclm: String = "AlDente"
