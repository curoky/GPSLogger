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

import Collections
import Foundation

class GPSLogHelper: NSObject {
    static let shared = GPSLogHelper()

    var logFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "/gps.log")

    var messageBuffer = Deque<String>()
    var bufferLimit = 20
    var bufferLock = NSLock()

    func log(message: String) {
        bufferLock.lock()
        defer { bufferLock.unlock() }

        messageBuffer.append(message + "size:\(messageBuffer.count % bufferLimit)\n")
        if messageBuffer.count > bufferLimit {
            messageBuffer.removeFirst(messageBuffer.count - bufferLimit)
        }

        let fileHandle = try! FileHandle(forWritingTo: logFilePath)
        fileHandle.seekToEndOfFile()
        fileHandle.write(message.data(using: .utf8)!)
        try! fileHandle.close()
    }

    override private init() {
        if !FileManager.default.fileExists(atPath: logFilePath.path()) {
            FileManager.default.createFile(atPath: logFilePath.path(), contents: "File created at:  \(ISO8601DateFormatter().string(from: Date()))\n\n".data(using: .utf8))
        }
    }

    func tailfLog() -> String {
        bufferLock.lock()
        defer { bufferLock.unlock() }
//        return messageBuffer.reversed().joined()
        return messageBuffer.joined()
    }
}
