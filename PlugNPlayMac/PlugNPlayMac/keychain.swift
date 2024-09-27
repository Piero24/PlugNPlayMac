//
//  keychain.swift
//  PlugNPlayMac
//
//  Created by Andrea Pietrobon on 21/09/24.
//

import Foundation
import Security


/// Retrieves the full name of the current macOS user.
///
/// This function uses `NSFullUserName()` to return the full name of the user currently logged into the system.
///
/// - Returns: The full name of the current user as a string.
///
/// - Example:
///   ```
///   let userName = getUserName()
///   print("Current user: \(userName)")
///   ```
///
/// - See Also: `NSFullUserName()`
func getUserName() -> String {
    return NSFullUserName()
}


/// Retrieves the password for a given service and account from the Keychain.
///
/// This function queries the Keychain for a generic password item associated with the specified
/// service and account. If a matching item is found, the password is returned as a string.
///
/// - Parameters:
///    - service: A string representing the service associated with the password (e.g., app or website name).
///    - account: A string representing the account associated with the password (e.g., username or email).
///
/// - Returns:
///    A `String?` containing the password if found, or `nil` if no password could be retrieved.
///
/// - Note:
///    The function uses `SecItemCopyMatching` to perform the query, which returns the result as
///    data in UTF-8 encoding.
///
/// - Important:
///    Ensure that the app has access to the Keychain, and that the correct service and account
///    are passed, otherwise this function will return `nil`.
///
/// - See Also:
///    [Apple Keychain Services Documentation](https://developer.apple.com/documentation/security/keychain_services)
func getPassword(_ service: String, _ account: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: account,
        kSecReturnData as String: kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var passwordData: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &passwordData)
    
    if status == errSecSuccess, let data = passwordData as? Data, let password = String(data: data, encoding: .utf8) {
        return password
    } else {
        printLog("E6", "Error when try to take the password from the keychain")
        return nil
    }
}
