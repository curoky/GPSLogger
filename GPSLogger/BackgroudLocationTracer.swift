//
//  BackgroudLocationTracer.swift
//  GPSLogger
//
//  Created by curoky on 2022/10/1.
//

import Foundation
import CoreData
import CoreLocation

typealias Listener = (CLLocation) -> ()

class BackgroudLocationTracer: NSObject {

    var locationManager =  CLLocationManager()

    func startMonitoring() {
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

extension BackgroudLocationTracer: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
