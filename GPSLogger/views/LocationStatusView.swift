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
import SwiftUI

struct LocationStatusView: View {
    @StateObject private var tracer = BackgroudLocationTracer()

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Coordinate:")
                    Spacer()
                    CopyableTextView(text: String(format: "%.5f, %.5f", tracer.currentLocation.coordinate.latitude, tracer.currentLocation.coordinate.longitude))
                }
                HStack {
                    Text("Altitude:")
                    Spacer()
                    Text(tracer.currentLocation.altitude, format: .number)
                }
                HStack {
                    Text("Speed:")
                    Spacer()
                    Text(String(format: "%.fm/s, %.fkm/h", tracer.currentLocation.speed, tracer.currentLocation.speed * 60 * 60 / 1000))
                }
                HStack {
                    Text("Course:")
                    Spacer()
                    Text(tracer.currentLocation.course, format: .number)
                }
                HStack {
                    Text("MovedDistance:")
                    Spacer()
                    Text(String(format: "%.3fkm", tracer.movedDistance / 1000))
                }
            }
            .padding(.leading, -5)
            .padding(.trailing, -5)

            Section {
                HStack {
                    Text("LastLocationTime:")
                    Spacer()
                    Text(formatDate(date: tracer.currentLocation.timestamp))
                }
                HStack {
                    Text("Uptime:")
                    Spacer()
                    Text(formatDate(date: tracer.initTS))
                }
//                HStack {
//                    Text("UptimeDur:")
//                    Spacer()
//                    Text(formatTimeDifference(startDate: tracer.currentLocation.timestamp, endDate: Date.now))
//                }
//                HStack {
//                    Text("lastHighPrecTime:")
//                    Spacer()
//                    Text(formatDate(date: tracer.lastSwitchToHighPrecisionTime))
//                }
                HStack {
                    Text("HighPrecDur:")
                    Spacer()
                    Text(formatTimeDifference(startDate: tracer.lastSwitchToHighPrecisionTime, endDate: Date.now))
                }
                HStack {
                    Text("UpdatedCount:")
                    Spacer()
                    Text(tracer.updatedCount, format: .number)
                }
            }
            .padding(.leading, -5)
            .padding(.trailing, -5)

            Section(header: Text("Control")) {
                HStack {
                    Toggle("", isOn: $tracer.isOnHighPrecision)
                        .onChange(of: tracer.isOnHighPrecision) { newValue in
                            tracer.updateTracerMode(enable: newValue)
                        }
                        .labelsHidden()
                    Button(action: onActionExport) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
                    // Button(action: onActionExportSync) {
                    //     Image(systemName: "arrow.triangle.2.circlepath.circle")
                    // }
                    // .buttonStyle(.borderedProminent)
                }
            }
            .padding(.leading, -5)
            .padding(.trailing, -5)

            Section {
                ForEach(ConfigManager.shared.config.positions, id: \.self) { loc in
                    HStack {
                        Text(" \(loc.name)<\(tracer.currentLocation.coordinate.latitude), \(tracer.currentLocation.coordinate.longitude)>: ")
                        Spacer()
                        Text(String(format: "%.3fkm",
                                    tracer.currentLocation.distance(from: CLLocation(
                                        latitude: loc.latitude,
                                        longitude: loc.longitude
                                    )) / 1000))
                    }
                }
            }
            .padding(.leading, -5)
            .padding(.trailing, -5)
        }
//        .scrollDisabled(true)
        .padding(.leading, -5)
        .padding(.trailing, -5)
        .onAppear {
            tracer.startMonitoring()
            LogManager.shared.addLogMessage("tracer.startMonitoring()")
        }
    }

    func onActionExport() {
        if let fileURL = ConfigManager.shared.getGPSLogSaveURL() {
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }

    func onActionExportSync() {
        // Copy the file to the iCloud directory
        if let sourceURL = ConfigManager.shared.getGPSLogSaveURL() {
            if let destinationURL = ConfigManager.shared.getICloudExportURL() {
                do {
                    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                    LogManager.shared.addLogMessage("File copied to iCloud directory.")
                } catch {
                    LogManager.shared.addLogMessage("Failed to copy file to iCloud directory: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct LocationStatusView_Previews: PreviewProvider {
    static var previews: some View {
        LocationStatusView()
    }
}

struct CopyableTextView: View {
    let text: String

    var body: some View {
        Text(text)
            .onTapGesture {
                UIPasteboard.general.string = text
            }
    }
}
