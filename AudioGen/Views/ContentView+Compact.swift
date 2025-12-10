//
//  ContentView+Compact.swift
//  AudioGen
//
//  Option 2: Inline Compact Horizontal Layout
//

import SwiftUI

struct ContentViewCompact: View {
    @StateObject private var viewModel = AudioGenerationViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Audio Generation")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Voice Selection - Compact Single Line
            HStack(spacing: 12) {
                Image(systemName: "person.wave.2")
                    .foregroundColor(.secondary)
                
                Text("Voice:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("", selection: $viewModel.selectedVoice) {
                    ForEach(viewModel.availableVoices) { voice in
                        Text(voice.name).tag(voice)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 110)
                
                Text("·")
                    .foregroundColor(.secondary)
                
                Text(viewModel.selectedVoice.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.vertical, 4)
            
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
    }
}

#Preview {
    ContentViewCompact()
}
