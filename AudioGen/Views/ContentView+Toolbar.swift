//
//  ContentView+Toolbar.swift
//  AudioGen
//
//  Option 1: Native macOS Toolbar Approach
//

import SwiftUI

struct ContentViewWithToolbar: View {
    @StateObject private var viewModel = AudioGenerationViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
                    .frame(minHeight: 200)
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
            
            Spacer()
        }
        .padding(24)
        .frame(minWidth: 600, minHeight: 500)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack(spacing: 8) {
                    Image(systemName: "person.wave.2")
                        .foregroundColor(.secondary)
                    
                    Picker("Voice", selection: $viewModel.selectedVoice) {
                        ForEach(viewModel.availableVoices) { voice in
                            Text(voice.name).tag(voice)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                    
                    Text(viewModel.selectedVoice.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: viewModel.generateAudio) {
                    HStack(spacing: 6) {
                        if viewModel.isGenerating {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 12, height: 12)
                        }
                        
                        Label(
                            viewModel.isGenerating ? "Generating..." : "Generate Audio",
                            systemImage: "waveform"
                        )
                    }
                }
                .disabled(!viewModel.canGenerate)
            }
        }
    }
}

#Preview {
    ContentViewWithToolbar()
}
