//
//  AppStatusView.swift
//  GPSLogger
//
//  Created by cicada on 2023/9/16.
//

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
            configuration = Config.shared.configContent
        }
    }

    func parseConfiguration() {
        isLoading = true
        Config.shared.saveAndReloadConfigFile(content: configuration)

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
