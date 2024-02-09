//
//  GeournalApp.swift
//  Geournal
//
//  Created by Colin Anderson on 1/19/24.
//

import SwiftUI

import SwiftData

@main
struct GeournalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PinData.self, TagData.self])
    }
}
