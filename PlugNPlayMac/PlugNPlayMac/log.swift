//
//  log.swift
//  PlugNPlayMac
//
//  Created by Andrea Pietrobon on 21/09/24.
//

import Foundation


/// Logs a message to the console with a timestamp, message type, and architecture indicator.
///
/// This function formats and prints a log message to the console. It includes the current date and time,
/// a message type (if provided), and an architecture indicator to show whether the code is running
/// on Apple Silicon (marked as `(A)`) or Intel-based architecture (marked as `(I)`).
///
/// - Parameters:
///    - messageType: A string representing the type of message (e.g., "INFO", "ERROR"). If empty, no message type is included.
///    - text: The actual message content to be logged.
///
/// - Example:
///    ```
///    printLog("INFO", "Application started successfully.")
///    ```
///
/// - Output:
///    ```
///    [2024-09-21 14:45:12] : INFO : (A) : Application started successfully.
///    ```
///
/// - Note:
///    The date format used is `yyyy-MM-dd HH:mm:ss`, and the architecture is detected by the
///    `isAppleSilicon()` function, which returns a boolean indicating the system's architecture.
///
/// - See Also:
///    `DateFormatter`, `isAppleSilicon()`
func printLog(_ messageType: String, _ text: String) {
    let currentDate = Date()

    let dateFormatter = DateFormatter()
    // Custom format to include time
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let formattedDate = dateFormatter.string(from: currentDate)
    
    let architectureIndicator = isAppleSilicon() ? "(A)" : "(I)"
    let messagePrefix = messageType.isEmpty ? "" : "\(messageType) : "
    print("[\(formattedDate)] : \(messagePrefix)\(architectureIndicator) : \(text)")
}
