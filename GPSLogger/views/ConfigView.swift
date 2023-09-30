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

struct ConfigView: View {
    @State private var configuration: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            TextEditor(text: $configuration)
                .border(Color.gray, width: 1)
                .padding()

            Button(action: {
                parseConfiguration()
            }) {
                Text("Load")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(configuration.isEmpty || isLoading)
        }
        .padding()
        .onAppear {
            configuration = ConfigManager.shared.configContent
        }
    }

    func parseConfiguration() {
        isLoading = true
        ConfigManager.shared.saveAndReloadConfigFile(content: configuration)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
        }
    }
}

struct AppStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView()
    }
}
