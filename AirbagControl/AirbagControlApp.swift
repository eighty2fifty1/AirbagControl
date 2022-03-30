//
//  AirbagControlApp.swift
//  AirbagControl
//
//  Created by James Ford on 3/19/22.
//

import SwiftUI

@main
struct AirbagControlApp: App {
    @StateObject var bleManager = BLEManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
        }
    }
}
