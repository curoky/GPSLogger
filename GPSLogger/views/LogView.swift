//
//  LogView.swift
//  GPSLogger
//
//  Created by cicada on 2023/9/17.
//

import SwiftUI

struct LogView: View {
    @State var logMessages: [LogMessage] = []

    var body: some View {
        VStack {
            Text("Logging")
                .font(.headline)
            ScrollView {
                LazyVStack {
                    ForEach(logMessages) { logMessage in
                        Text("\(logMessage.timestamp.ISO8601Format()):  \(logMessage.message)")
                    }
                }
            }
            Button(action: onActionExport) {
                Image(systemName: "arrow.clockwise.circle")
            }
            .buttonStyle(.borderedProminent)
        }
//        .padding()
    }

    func onActionExport() {
        logMessages = LogManager.shared.logMessages
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
