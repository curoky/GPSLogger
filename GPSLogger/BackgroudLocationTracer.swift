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
    var stopedLocation: [CLLocation] = []

    @Published var currentLocation: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    @Published var currentAltitude: Double = 0
    @Published var updatedCount: Int = 0
    @Published var isOnHighPrecision: Bool = false
    @Published var lastSwithedHighPrecisionTime = Date.now
    @Published var currentMessage: String = ""

    func startMonitoring() {
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.distanceFilter = 50
        switchTracerMode(highPrecision: true)
        locationManager.delegate = self
    }

    func switchTracerMode(highPrecision: Bool) {
        if isOnHighPrecision == highPrecision {
            return
        }
        isOnHighPrecision = highPrecision
        if highPrecision {
            lastSwithedHighPrecisionTime = Date.now
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }

    func getLogFileURL() -> URL? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsDirectory.appendingPathComponent("gps_log.txt")
        }
        return nil
    }
}

extension BackgroudLocationTracer: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
            currentAltitude = loc.altitude
            currentLocation = loc.coordinate
            updatedCount += 1
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

                if let logFileURL = getLogFileURL() {
                    if !FileManager.default.fileExists(atPath: logFileURL.path()) {
                        FileManager.default.createFile(atPath: logFileURL.path(), contents: nil)
                    }

                    let fileHandle = try FileHandle(forWritingTo: logFileURL)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(jsonData)
                    fileHandle.closeFile()
                }

            } catch {
                print("保存JSON文件失败：\(error)")
            }

            if isOnHighPrecision {
                for mp in stopedLocation {
                    if loc.distance(from: mp) < 50 {
                        let diffComponents = Calendar.current.dateComponents([.minute], from: lastSwithedHighPrecisionTime, to: Date.now)
                        if diffComponents.minute! < 10 {
                        } else {
                            switchTracerMode(highPrecision: false)
                        }
                    }
                }
            } else {
                var inAnyOne = false
                for mp in stopedLocation {
                    if loc.distance(from: mp) < 100 {
                        inAnyOne = true
                    }
                }
                if !inAnyOne {
                    switchTracerMode(highPrecision: true)
                }
            }
            break
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
