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

import SwiftUI

struct ContentView: View {
    @State private var onHighPrecision = false
    @State private var logMessage = ""

    var body: some View {
        VStack {
            TextEditor(text: .constant(logMessage))
                .foregroundColor(.black)
                .padding(.horizontal)
                .font(/*@START_MENU_TOKEN@*/ .title3/*@END_MENU_TOKEN@*/)

            HStack {
                Toggle(isOn: $onHighPrecision) {}.labelsHidden()

                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    logMessage += "123\n"
                }) {
                    Image(systemName: "gobackward")
                }
                .buttonStyle(.borderedProminent)

            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
