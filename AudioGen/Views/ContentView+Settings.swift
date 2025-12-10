//
//  ContentView+Settings.swift
//  AudioGen
//
//  Option 3: Settings Sheet Approach
//

import SwiftUI

struct ContentViewWithSettings: View {
    @StateObject private var viewModel = AudioGenerationViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with Settings Button
            HStack {
                Text("Audio Generation")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingSettings = true }) {
                    Label("Settings", systemImage: "gearshape")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.plain)
                .font(.title2)
            }
            
            // Voice indicator (read-only, click to change)
            Button(action: { showingSettings = true }) {
                HStack {
                    Image(systemName: "person.wave.2")
                        .foregroundColor(.accentColor)
                    
                    Text("Voice:")
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.selectedVoice.name)
                        .fontWeight(.medium)
                    
                    Text("·")
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.selectedVoice.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.accentColor.opacity(0.08))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            // Text Input Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Text to Convert", systemImage: "text.quote")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(viewModel.characterCount) / 4096")
                        .font(.caption)
                        .foregroundColor(viewModel.isNearCharacterLimit ? .orange : .secondary)
                }
                
                TextEditor(text: $viewModel.textInput)
                    .font(.body)
                    .frame(minHeight: 150)
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.isNearCharacterLimit ? Color.orange : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        if viewModel.textInput.isEmpty {
                            Text("Enter the text you want to convert to speech...")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
            }
            
            // Instructions Section
            VStack(alignment: .leading, spacing: 8) {
                Label("Instructions", systemImage: "list.bullet.clipboard")
                    .font(.headline)
                
                TextEditor(text: $viewModel.instructions)
                    .font(.body)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        if viewModel.instructions.isEmpty {
                            Text("Optional: Add voice instructions, tone, or style preferences...")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
            }
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Action Button
            HStack {
                Spacer()
                
                Button(action: viewModel.generateAudio) {
                    HStack(spacing: 8) {
                        if viewModel.isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 16, height: 16)
                        }
                        
                        Label(
                            viewModel.isGenerating ? "Generating..." : "Generate Audio",
                            systemImage: "waveform"
                        )
                        .font(.headline)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canGenerate)
            }
            
            Spacer()
        }
        .padding(24)
        .frame(minWidth: 600, minHeight: 500)
        .sheet(isPresented: $showingSettings) {
            SettingsSheet(viewModel: viewModel)
        }
    }
}

struct SettingsSheet: View {
    @ObservedObject var viewModel: AudioGenerationViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            
            Divider()
            
            VoicePickerView(
                voices: viewModel.availableVoices,
                selectedVoice: $viewModel.selectedVoice,
                isLoading: viewModel.isLoadingVoices
            )
            
            Spacer()
        }
        .padding(24)
        .frame(width: 450, height: 300)
    }
}

#Preview {
    ContentViewWithSettings()
}
