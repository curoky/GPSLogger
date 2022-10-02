//
//  GPSLogHelper.swift
//  GPSLogger
//
//  Created by curoky on 2022/10/1.
//

import Foundation

class GPSLogHelper: NSObject {
    
    static let shared = GPSLogHelper()
    
    var logFilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].appending("/gps.log")
    
    var messageBuffer:[String] = []
    var bufferLock: NSLock = NSLock()
    
    func log(message: String) {
        bufferLock.lock()
        defer { bufferLock.unlock() }

//        print("GPSLogHelper:log: \(message), size:\(messageBuffer.count)")
        messageBuffer.append(message + "size:\(messageBuffer.count)\n")
        if messageBuffer.count > 100 {
            let fileHandle = FileHandle(forWritingAtPath: logFilePath)!
            fileHandle.seekToEndOfFile()
            for m in messageBuffer {
                fileHandle.write(m.data(using: .utf8)!)
            }
            try? fileHandle.close()
            messageBuffer.removeAll(keepingCapacity: true)
        }
    }
    
    // Make sure the class has only one instance
    // Should not init or copy outside
    private override init() {
        messageBuffer.reserveCapacity(100)
        print("init: \(logFilePath)")
        if !FileManager.default.fileExists(atPath: logFilePath) {
            FileManager.default.createFile(atPath: logFilePath, contents: "File created at:  \(ISO8601DateFormatter().string(from: Date()))\n\n".data(using: .utf8))
        }
    }
    
    func tailfLog() -> String {
        bufferLock.lock()
        defer { bufferLock.unlock() }
        return messageBuffer.reversed().joined()

//        do {
//            return try String(contentsOf: URL(filePath: logFilePath), encoding: .utf8)
//        } catch {
//            return "tailfLog failed!\(error)"
//        }
    }
    
    override func copy() -> Any {
        return self // GPSLogHelper.shared
    }
    
    override func mutableCopy() -> Any {
        return self // GPSLogHelper.shared
    }
    
    // Optional
    func reset() {
        // Reset all properties to default value
    }
}
