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

typealias Listener = (CLLocation) -> Void

class BackgroudLocationTracer: NSObject {
    static let shared = BackgroudLocationTracer()
    var isOnHighPrecision = false
    var locationManager = CLLocationManager()

    func startMonitoring() {
        GPSLogHelper.shared.log(message: "====== startMonitoring \n")
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
        GPSLogHelper.shared.log(message: "====== switchTracerMode \(highPrecision)\n")
        isOnHighPrecision = highPrecision
        if highPrecision {
            GPSLogHelper.shared.log(message: "====== startUpdatingLocation \n")
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        } else {
            GPSLogHelper.shared.log(message: "====== startMonitoringSignificantLocationChanges \n")
            locationManager.stopUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
}

extension BackgroudLocationTracer: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let jsonData = try! encoder.encode(["timestamp": loc.timestamp.description,
                                                "speed": loc.speed.description,
                                                "latitude": loc.coordinate.latitude.description,
                                                "longitude": loc.coordinate.longitude.description,
                                                "altitude": loc.altitude.description,
                                                "course": loc.course.description,
                                                "speedAccuracy": loc.speedAccuracy.description,
                                                "ellipsoidalAltitude": loc.ellipsoidalAltitude.description,
                                                "horizontalAccuracy": loc.horizontalAccuracy.description,
                                                "verticalAccuracy": loc.verticalAccuracy.description,
                                                "courseAccuracy": loc.courseAccuracy.description])
            GPSLogHelper.shared.log(message: (String(data: jsonData, encoding: .utf8) ?? "error in loc to json") + "\n")

            if isOnHighPrecision {
                for mp in MY_LIVE_POSITIONS {
                    if loc.distance(from: mp) < 50 {
                        GPSLogHelper.shared.log(message: "====== < 50 stop \n")
                        switchTracerMode(highPrecision: false)
                    }
                }
            } else {
                var inAnyOne = false
                for mp in MY_LIVE_POSITIONS {
                    if loc.distance(from: mp) < 500 {
                        inAnyOne = true
                    }
                }
                if !inAnyOne {
                    GPSLogHelper.shared.log(message: "====== > 500 start \n")
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
