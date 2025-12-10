//
//  AudioGenApp.swift
//  AudioGen
//
//  Created by Guillermo Vertel on 18/11/25.
//

import SwiftUI

@main
struct AudioGenApp: App {
    var body: some Scene {
        WindowGroup {
            MainNavigationView()
        }
        .windowStyle(.automatic)
        .defaultSize(width: 900, height: 600)
    }
}
