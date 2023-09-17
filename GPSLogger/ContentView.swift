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
    var body: some View {
        TabView {
            LocationStatusView().tabItem {
                Image(systemName: "location.circle")
                Text("GPS")
            }
            MapView().tabItem {
                Image(systemName: "mappin.and.ellipse")
                Text("Map")
            }
            ConfigView().tabItem {
                Image(systemName: "gear")
                Text("Setting")
            }
            LogView().tabItem {
                Image(systemName: "slowmo")
                Text("logging")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
