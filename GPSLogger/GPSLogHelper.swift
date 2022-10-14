/*
 * Copyright (c) 2022-2022 curoky(cccuroky@gmail.com).
 *
 * This file is part of GPSLogger.
 * See https://github.com/curoky/GPSLogger for further info.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

class GPSLogHelper: NSObject {
    static let shared = GPSLogHelper()

    var logFilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].appending("/gps.log")

    var messageBuffer: [String] = []
    var bufferLock: NSLock = .init()

    func log(message: String) {
        bufferLock.lock()
        defer { bufferLock.unlock() }

        messageBuffer.append(message + "size:\(messageBuffer.count)\n")
        if messageBuffer.count > 20 {
            let fileHandle = FileHandle(forWritingAtPath: logFilePath)!
            fileHandle.seekToEndOfFile()
            for m in messageBuffer {
                fileHandle.write(m.data(using: .utf8)!)
            }
            try! fileHandle.close()
            messageBuffer.removeAll(keepingCapacity: true)
        }
    }

    override private init() {
        if !FileManager.default.fileExists(atPath: logFilePath) {
            FileManager.default.createFile(atPath: logFilePath, contents: "File created at:  \(ISO8601DateFormatter().string(from: Date()))\n\n".data(using: .utf8))
        }
    }

    func tailfLog() -> String {
        bufferLock.lock()
        defer { bufferLock.unlock() }
        return messageBuffer.reversed().joined()
    }
}
