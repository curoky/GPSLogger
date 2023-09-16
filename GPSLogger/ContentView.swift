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

struct ContentView: View {
    @StateObject private var tracer = BackgroudLocationTracer()
    @StateObject private var config = Config()
    @State private var configText: String = ""

    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { _ in
                List {
                    HStack {
                        Text("latitude:")
                        Spacer()
                        Text("\(tracer.currentLocation.latitude)")
                            .onTapGesture {
                                UIPasteboard.general.string = String(tracer.currentLocation.latitude)
                            }
                    }
                    HStack {
                        Text("longitude:")
                        Spacer()
                        Text("\(tracer.currentLocation.longitude)")
                            .onTapGesture {
                                UIPasteboard.general.string = String(tracer.currentLocation.longitude)
                            }
                    }
                    HStack {
                        Text("Altitude:")
                        Spacer()
                        Text("\(tracer.currentAltitude)")
                            .onTapGesture {
                                UIPasteboard.general.string = String(tracer.currentAltitude)
                            }
                    }
                    HStack {
                        Text("Update size:")
                        Spacer()
                        Text("\(tracer.updatedCount)")
                    }
                }
            }
            GeometryReader { _ in
                List {
                    ForEach(config.stopedLocation, id: \.self) { loc in
                        Text("\(loc.coordinate.latitude):\(loc.coordinate.longitude)")
                    }
                }
            }
            GeometryReader { _ in
                Text("Message: \(tracer.currentMessage)").padding()
            }
            GeometryReader { _ in
                TextEditor(text: $configText)
            }
            Spacer()
            HStack {
                Button(action: onConfigSave) {
                    Image(systemName: "square.and.arrow.down.fill")
                }
                .buttonStyle(.borderedProminent)
                Button(action: onConfigLoad) {
                    Image(systemName: "square.and.arrow.up.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            HStack {
                Toggle(isOn: $tracer.isOnHighPrecision) {}
                    .labelsHidden()
                    .onChange(of: tracer.isOnHighPrecision, perform: onToggleHighPrecision)
                Button(action: onActionExport) {
                    Image(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
                Button(action: onActionRefresh) {
                    Image(systemName: "gobackward")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    func onConfigSave() {
        config.save(content: configText)
    }

    func onConfigLoad() {
        config.load()
    }

    func onToggleHighPrecision(equatable _: any Equatable) {
        tracer.switchTracerMode(highPrecision: tracer.isOnHighPrecision)
    }

    func onActionExport() {
        if let fileURL = tracer.getLogFileURL() {
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }

    func onActionRefresh() {
        tracer.startMonitoring()
        tracer.stopedLocation = config.stopedLocation
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
