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

import CoreData
import CoreLocation
import Foundation
import SwiftUI

class BackgroudLocationTracer: NSObject, ObservableObject {
    var locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation = .init(latitude: 0, longitude: 0) // kCLLocationCoordinate2DInvalid
    @Published var updatedCount: Int = 0
    @Published var isOnHighPrecision: Bool = true
    @Published var lastSwitchHighPrecisionTime = Date.now
    @Published var currentMessage: String = ""
    @Published var isInStoppedPositon: Bool = false
    @Published var beginLocation: CLLocation = .init(latitude: 0, longitude: 0)
    @Published var cumulativeDistance: Double = 0

    func startMonitoring() {
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.distanceFilter = 50
        updateTracerMode(enable: true)
        locationManager.delegate = self
    }

    func updateTracerMode(enable: Bool) {
        isOnHighPrecision = enable
        LogManager.shared.addLogMessage("updateTracerMode: \(isOnHighPrecision)")
        if isOnHighPrecision {
            lastSwitchHighPrecisionTime = Date.now
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
}

extension BackgroudLocationTracer: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
            if updatedCount > 1 {
                cumulativeDistance += currentLocation.distance(from: loc)
            }
            updatedCount += 1
            currentLocation = loc
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: ["timestamp": loc.timestamp.description,
                                                                           "speed": loc.speed.description,
                                                                           "latitude": loc.coordinate.latitude.description,
                                                                           "longitude": loc.coordinate.longitude.description,
                                                                           "altitude": loc.altitude.description,
                                                                           "course": loc.course.description,
                                                                           "speedAccuracy": loc.speedAccuracy.description,
                                                                           "ellipsoidalAltitude": loc.ellipsoidalAltitude.description,
                                                                           "horizontalAccuracy": loc.horizontalAccuracy.description,
                                                                           "verticalAccuracy": loc.verticalAccuracy.description,
                                                                           "courseAccuracy": loc.courseAccuracy.description], options: .sortedKeys)

                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    currentMessage = jsonString
                }

                if let logFileURL = Config.shared.getGPSLogSaveURL() {
                    if !FileManager.default.fileExists(atPath: logFileURL.path()) {
                        FileManager.default.createFile(atPath: logFileURL.path(), contents: nil)
                    }

                    let fileHandle = try FileHandle(forWritingTo: logFileURL)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(jsonData)
                    fileHandle.closeFile()
                }

            } catch {
                LogManager.shared.addLogMessage("save json failed：\(error)")
            }

            isInStoppedPositon = false
            if isOnHighPrecision {
                for mp in Config.shared.stopedLocation {
                    if loc.distance(from: mp) < 50 {
                        isInStoppedPositon = true
                        let diffComponents = Calendar.current.dateComponents([.minute], from: lastSwitchHighPrecisionTime, to: Date.now)
                        if diffComponents.minute! < 10 {
                        } else {
                            updateTracerMode(enable: false)
                        }
                    }
                }
            } else {
                var inAnyOne = false
                for mp in Config.shared.stopedLocation {
                    if loc.distance(from: mp) < 100 {
                        isInStoppedPositon = true
                        inAnyOne = true
                    }
                }
                if !inAnyOne {
                    updateTracerMode(enable: true)
                }
            }
            break
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        LogManager.shared.addLogMessage("\(error)")
    }
}
