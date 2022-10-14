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

import CoreGPX
import CoreLocation
import UIKit

class LoggingVC: UIViewController {
    @IBOutlet var logTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func fetchLogClicked(_: Any) {
        logTextView.text = GPSLogHelper.shared.tailfLog()
    }

    @IBAction func exportGPXClicked(_: Any) {
        let content = try! String(contentsOfFile: GPSLogHelper.shared.logFilePath, encoding: .utf8)
        let data = content.split(separator: "\n")
            .filter { $0.starts(with: "=>|") }
            .map {
                $0.split(separator: "|")[1]
                    .split(separator: ",")
                    .map { $0.split(separator: "=") }
            }
        print("count=\(data.count)")

        let root = GPXRoot(creator: "GPSLogger!")
        let track = GPXTrack()
        let tracksegment = track.newTrackSegment()
        root.add(track: track)

        for l in data {
            let dateformater = DateFormatter()
            dateformater.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let tp = tracksegment.newTrackpointWith(latitude: 0, longitude: 0)
            for kv in l {
                switch kv[0] {
                case "latitude": tp.latitude = Double(kv[1])
                case "longitude": tp.longitude = Double(kv[1])
                case "altitude": tp.elevation = Double(kv[1])
                case "timestamp": tp.time = dateformater.date(from: String(kv[1]))
                default: continue
                }
            }
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("GPSLogger")
            .appendingPathExtension("gpx")
        try! root.gpx().write(to: url, atomically: true, encoding: .utf8)

        present(UIActivityViewController(activityItems: [url], applicationActivities: nil),
                animated: true, completion: nil)
    }

    @IBAction func exportLogClicked(_: Any) {
        present(UIActivityViewController(
            activityItems: [URL(filePath: GPSLogHelper.shared.logFilePath)],
            applicationActivities: nil
        ),
        animated: true, completion: nil)
    }
}
