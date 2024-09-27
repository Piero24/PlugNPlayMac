//
//  bclm.swift
//  PlugNPlayMac
//
//  Created by Andrea Pietrobon on 22/09/24.
//

import Foundation
import Cocoa


/// Sets the battery charge limit (BCLM) for the system.
///
/// This function overwrites the battery charge limit using the `bclm` tool. The value is either set to 80 or 100 for Apple Silicon devices.
/// It writes the value, applies persistence, and reads the result back to verify the operation.
///
/// - Parameter value: The desired battery limit value (typically 80 or 100 for Apple Silicon).
/// - Returns: The battery limit value after being applied, or -1 if an error occurred.
///
/// - Note: The function interacts with the shell, uses `sudo`, and expects to have access to the `bclm` tool.
/// - See Also: https://github.com/zackelia/bclm
func setBclm(_ value: Int) -> Int {
    // More info on BCLM here: https://github.com/zackelia/bclm
    // Overwrite battery value and set the new value for the battery limit
    // chmod +x "\(mainPath)/bclm"
    let bclmPath: String = "\(mainPath)/bclm"
    var isBclmWorking = true
    var batteryResult: Int = -1

    if isAppleSilicon() {
        // FOR APPLE SILICON THE VALUE MUST BE 80 or 100
        inputParams.batteryValue = 80
    }
    
    // Write the battery value
    do {
        let writeProcess = Process()
        writeProcess.executableURL = URL(fileURLWithPath: "/bin/sh")
        writeProcess.arguments = ["-c", "echo \(getPassword("PlugNPlayMac", account) ?? "") | sudo -S \(bclmPath) write \(inputParams.batteryValue) 2>&1"]
        
        let pipe = Pipe()
        writeProcess.standardOutput = pipe
        writeProcess.standardError = pipe
        
        try writeProcess.run()
        writeProcess.waitUntilExit()

        // Capture the output
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        var output = String(data: data, encoding: .utf8) ?? ""
        
        if writeProcess.terminationStatus == 0 && output == "Password:" {
            printLog("S5", "Value \(inputParams.batteryValue) written successfully")
        } else {
            if output.hasSuffix("\n") {output.removeLast()}
            isBclmWorking = false
            printLog("E5", "BCLM write command failed with output: \(output)")
        }
    } catch {
        isBclmWorking = false
        printLog("E5", "Problem writing the battery value: \(error)")
    }

    // Apply persistence for the new battery limit
    do {
        let persistProcess = Process()
        persistProcess.executableURL = URL(fileURLWithPath: "/bin/sh")
        persistProcess.arguments = ["-c", "echo \(getPassword("PlugNPlayMac", account) ?? "") | sudo -S \(bclmPath) persist 2>&1"]
        
        let pipe = Pipe()
        persistProcess.standardOutput = pipe
        persistProcess.standardError = pipe
        
        try persistProcess.run()
        persistProcess.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        var output = String(data: data, encoding: .utf8) ?? ""
        
        if persistProcess.terminationStatus == 0 && output == "Password:" {
            printLog("S5", "Persistence has been activated")
        } else {
            if output.hasSuffix("\n") {output.removeLast()}
            isBclmWorking = false
            printLog("E5", "BCLM persist command failed with output: \(output)")
        }
    } catch {
        isBclmWorking = false
        printLog("E5", "Can't apply persistence: \(error)")
    }

    
    // Read the current battery value
    do {
        let readProcess = Process()
        readProcess.executableURL = URL(fileURLWithPath: "/bin/sh")
        
        // Create pipes to capture the output and errors
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        readProcess.standardOutput = outputPipe
        readProcess.standardError = errorPipe
        readProcess.arguments = ["-c", "\(bclmPath) read"]
        
        try readProcess.run()
        readProcess.waitUntilExit()
        
        // Capture the standard output
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        var output = String(data: outputData, encoding: .utf8) ?? ""
        
        // Capture the standard error
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        var errorOutput = String(data: errorData, encoding: .utf8) ?? ""
        
        if readProcess.terminationStatus == 0 {
            if let resultInt = Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) {
                batteryResult = resultInt
                printLog("S5", "Result of bclm read: \(batteryResult)")
            } else {
                if output.hasSuffix("\n") {output.removeLast()}
                isBclmWorking = false
                printLog("E5", "Failed to convert bclm read result to Int, output: \(output)")
            }
        } else {
            if output.hasSuffix("\n") {output.removeLast()}
            if errorOutput.hasSuffix("\n") {errorOutput.removeLast()}
            isBclmWorking = false
            printLog("E5", "BCLM read command failed with error: \(errorOutput), output: \(output)")
        }
    } catch {
        isBclmWorking = false
        printLog("E5", "Can't read the battery value: \(error)")
    }
    
    if !isBclmWorking {
        printLog("E5", "Problem during the BCLM activation. Try with AlDente")
        openAppByNameInBackground(appName: alternativeBclm)
    }
    return batteryResult
}


func setBclmUnpersist() -> Bool {
    // More info on BCLM here: https://github.com/zackelia/bclm
    let bclmPath: String = "\(mainPath)/bclm"
    
    do {
        let writeProcess = Process()
        writeProcess.executableURL = URL(fileURLWithPath: "/bin/sh")
        
        // Prepare pipes for capturing output and error
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        writeProcess.arguments = ["-c", "echo \(getPassword("PlugNPlayMac", account) ?? "") | sudo -S \(bclmPath) unpersist"]
        writeProcess.standardOutput = outputPipe
        writeProcess.standardError = errorPipe
        
        try writeProcess.run()
        writeProcess.waitUntilExit()
        
        // Capture output and error
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        var errorOutput = String(data: errorData, encoding: .utf8) ?? ""
        
        if writeProcess.terminationStatus == 0 {
            printLog("S5", "Persistence has been disabled successfully. Output: \(output)")
            return true
        } else {
            if errorOutput.hasSuffix("\n") {errorOutput.removeLast()}
            printLog("E5", "Failed to disable persistence. Error: \(errorOutput)")
            return false
        }
    } catch {
        printLog("E5", "Error during disabling persistence: \(error)")
        return false
    }
}


func removeFilePlistBclm(password: String, filePath: String) {
    var isBclmWorking = true
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    
    // Prepare the shell command to remove the file using sudo
    let command = "echo \(password) | sudo -S rm \(filePath)"
    process.arguments = ["-c", command]
    
    // Prepare pipes for capturing output and errors
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    
    do {
        try process.run()
        process.waitUntilExit()
        
        // Capture output and error
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        var errorOutput = String(data: errorData, encoding: .utf8) ?? ""
        
        if process.terminationStatus == 0 {
            printLog("S5", "File \(filePath) removed successfully. Output: \(output)")
        } else {
            if errorOutput.hasSuffix("\n") {errorOutput.removeLast()}
            isBclmWorking = false
            printLog("E5", "Failed to remove file. Error: \(errorOutput)")
        }
    } catch {
        isBclmWorking = false
        printLog("E5", "Error removing file: \(error)")
    }
    
    if !isBclmWorking {
        printLog("E5", "Problem during the BCLM deactivation. Try with AlDente")
        closeAppByName(appName: alternativeBclm)
    }
}
