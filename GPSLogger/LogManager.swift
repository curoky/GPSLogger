//
//  LogManager.swift
//  GPSLogger
//
//  Created by cicada on 2023/9/17.
//

import Foundation
import SwiftUI

struct LogMessage: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: Date
}

class LogManager: NSObject {
    static let shared = LogManager()

    var logMessages: [LogMessage] = []

    func addLogMessage(_ message: String) {
        let logMessage = LogMessage(message: message, timestamp: Date())
        logMessages.append(logMessage)
    }
}
