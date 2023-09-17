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

import SwiftUI

struct LocationStatusView: View {
    @StateObject private var tracer = BackgroudLocationTracer()

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Latitude:")
                    Spacer()
                    Text(tracer.currentLocation.coordinate.latitude, format: .number)
                }
                HStack {
                    Text("longitude:")
                    Spacer()
                    Text(tracer.currentLocation.coordinate.longitude, format: .number)
                }
                HStack {
                    Text("altitude:")
                    Spacer()
                    Text(tracer.currentLocation.altitude, format: .number)
                }
                HStack {
                    Text("Speed:")
                    Spacer()
                    Text(String(format: "%.fm/s", tracer.currentLocation.speed))
                }
                HStack {
                    Text("course:")
                    Spacer()
                    Text(tracer.currentLocation.course, format: .number)
                }
                HStack {
                    Text("cumulativeDistance:")
                    Spacer()
                    Text(tracer.cumulativeDistance, format: .number)
                }
            }
            .padding(.leading, -5)
            .padding(.trailing, -5)

            Section {
                HStack {
                    Text("updateTime:")
                    Spacer()
                    Text(tracer.currentLocation.timestamp, format: .iso8601)
                }
                HStack {
                    Text("lastHighPrecTime:")
                    Spacer()
                    Text(tracer.lastSwitchHighPrecisionTime, format: .iso8601)
                }
                HStack {
                    Text("updatedCount:")
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
                }
            }
            .padding(.leading, -5)
            .padding(.trailing, -5)

            Section {
                ForEach(Config.shared.stopedLocation, id: \.self) { loc in
                    HStack {
                        Text(" \(tracer.currentLocation.coordinate.latitude):\(tracer.currentLocation.coordinate.longitude): ")
                        Spacer()
                        Text(String(format: "%.fm", tracer.currentLocation.distance(from: loc)))
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
        if let fileURL = Config.shared.getGPSLogSaveURL() {
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
}

struct LocationStatusView_Previews: PreviewProvider {
    static var previews: some View {
        LocationStatusView()
    }
}
