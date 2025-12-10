//
//  MainNavigationView.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import SwiftUI

enum NavigationItem: String, CaseIterable {
    case generate = "Generate"
    case library = "Library"
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .generate: return "waveform"
        case .library: return "folder.fill"
        case .settings: return "gear"
        }
    }
}

struct MainNavigationView: View {
    @State private var selectedItem: NavigationItem = .generate
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(NavigationItem.allCases, id: \.self, selection: $selectedItem) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.icon)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 220)
        } detail: {
            // Main content area
            Group {
                switch selectedItem {
                case .generate:
                    ContentView()
                case .library:
                    LibraryView()
                case .settings:
                    SettingsView()
                }
            }
        }
        .navigationTitle("AudioGen")
    }
}

#Preview {
    MainNavigationView()
        .frame(width: 900, height: 600)
}
