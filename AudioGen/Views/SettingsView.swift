//
//  SettingsView.swift
//  AudioGen
//
//  Created on November 20, 2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    @State private var showingFolderPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
            
            Divider()
            
            // OpenAI API Key Section
            VStack(alignment: .leading, spacing: 12) {
                Text("OpenAI API Key")
                    .font(.headline)
                
                HStack {
                    SecureField("sk-...", text: $settings.openAIKey)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 400)
                    
                    if !settings.openAIKey.isEmpty {
                        Button(action: { settings.openAIKey = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Text("Your API key is stored locally and never shared.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Downloads Folder Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Downloads Folder")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(settings.downloadsFolderURL.path)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Text("Audio files will be downloaded to this location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Choose Folder...") {
                        showFolderPicker()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Reset to Default") {
                        settings.resetToDefault()
                    }
                    .buttonStyle(.borderless)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 600, minHeight: 300)
    }
    
    private func showFolderPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Download Folder"
        panel.message = "Choose where audio files will be downloaded"
        panel.directoryURL = settings.downloadsFolderURL
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                settings.downloadsFolderURL = url
            }
        }
    }
}

#Preview {
    SettingsView()
}
