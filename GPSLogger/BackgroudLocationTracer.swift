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

import CoreData
import CoreLocation
import Foundation

typealias Listener = (CLLocation) -> Void

class BackgroudLocationTracer: NSObject {
    static let shared = BackgroudLocationTracer()

    var locationManager = CLLocationManager()

    func startMonitoring() {
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

extension BackgroudLocationTracer: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var res = "=>|"
        for loc in locations {
            res.append("""
            timestamp=\(loc.timestamp),\
            speed=\(loc.speed),\
            latitude=\(loc.coordinate.latitude),\
            longitude=\(loc.coordinate.longitude),\
            altitude=\(loc.altitude),\
            course=\(loc.course),\
            speedAccuracy=\(loc.speedAccuracy),\
            ellipsoidalAltitude=\(loc.ellipsoidalAltitude),\
            horizontalAccuracy=\(loc.horizontalAccuracy),\
            verticalAccuracy=\(loc.verticalAccuracy),\
            courseAccuracy=\(loc.courseAccuracy)|
            """)
        }
//        GPSLogHelper.shared.log(message: String(locations.description))
        GPSLogHelper.shared.log(message: res)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
