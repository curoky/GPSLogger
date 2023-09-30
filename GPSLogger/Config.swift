/*
 * Copyright (c) 2022-2023 curoky(cccuroky@gmail.com).
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

import CoreLocation
import Foundation
import SwiftUI

class Config: NSObject {
    static let shared = Config()
    var stopedLocation: [CLLocation] = []
    var configContent: String = ""

    override init() {
        super.init()
        loadConfigFile()
    }

    func loadConfigFile() {
        if let configFile = getConfigFileURL() {
            if !FileManager.default.fileExists(atPath: configFile.path()) {
                return
            }
            stopedLocation.removeAll()
            do {
                configContent = try String(contentsOf: configFile, encoding: .utf8)
                let lines = configContent.components(separatedBy: .newlines)
                for line in lines {
                    let components = line.components(separatedBy: ",")
                    if components.count == 2, let x = Double(components[0]), let y = Double(components[1]) {
                        stopedLocation.append(CLLocation(latitude: x, longitude: y))
                    }
                }
            } catch {
                LogManager.shared.addLogMessage("Error reading configuration file: \(error)")
            }
        }
    }

    func saveAndReloadConfigFile(content: String) {
        if let configFile = getConfigFileURL() {
            if !FileManager.default.fileExists(atPath: configFile.path()) {
                FileManager.default.createFile(atPath: configFile.path(), contents: nil)
            }
            do {
                try content.write(to: configFile, atomically: true, encoding: .utf8)
                LogManager.shared.addLogMessage("Configuration saved to file: \(configFile.path)")
                loadConfigFile()
            } catch {
                LogManager.shared.addLogMessage("Error saving configuration to file: \(error)")
            }
        }
    }

    func getConfigFileURL() -> URL? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsDirectory.appendingPathComponent("config.txt")
        }
        return nil
    }

    func getGPSLogSaveURL() -> URL? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsDirectory.appendingPathComponent("gps_log.txt")
        }
        return nil
    }

    func getICloudExportURL() -> URL? {
        if let iCloudContainerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
            return iCloudContainerURL.appendingPathComponent("gps_log2.txt")
        } else {
            LogManager.shared.addLogMessage("Can't find iCloud container, please check network.")
        }
        return nil
    }
}
