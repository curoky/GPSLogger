//
//  LogView.swift
//  GPSLogger
//
//  Created by cicada on 2023/9/17.
//

import SwiftUI

struct LogView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Logging")
                .font(.headline)
                .padding(.bottom, 10)

            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(LogManager.shared.logMessages) { logMessage in
                        Text("\(logMessage.timestamp): \(logMessage.message)")
                    }
                }
            }
        }
        .padding()
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
