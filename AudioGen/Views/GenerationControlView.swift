//
//  GenerationControlView.swift
//  AudioGen
//
//  Created by GitHub Copilot on 09/12/25.
//

import SwiftUI

struct GenerationControlView: View {
    @Binding var errorMessage: String?
    @Binding var lastGeneratedAudioURL: URL?
    let isGenerating: Bool
    let canGenerate: Bool
    
    let onGenerate: () -> Void
    let onCancel: () -> Void
    let onClearError: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Error message
            if let errorMessage = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundColor(.red)
                    Button(NSLocalizedString("common.dismiss", comment: "Dismiss button title")) {
                        onClearError()
                    }
                    .buttonStyle(.borderless)
                    .padding(.leading, 8)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Success message with audio player
            if let audioURL = lastGeneratedAudioURL {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(NSLocalizedString("generation.success", comment: "Generation success message"))
                        .font(.callout)
                        .foregroundColor(.green)
                    Button(NSLocalizedString("generation.open_in_finder", comment: "Open in Finder button title")) {
                        NSWorkspace.shared.selectFile(audioURL.path, inFileViewerRootedAtPath: audioURL.deletingLastPathComponent().path)
                    }
                    .buttonStyle(.borderless)
                    .padding(.leading, 8)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }

            Spacer()
            
            // Generate Button
            if isGenerating {
                Button(NSLocalizedString("generation.button.cancel", comment: "Cancel button title")) {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                .padding(.trailing, 8)
            }
            
            Button(action: onGenerate) {
                HStack(spacing: 6) {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 12, height: 12)
                    }
                    
                    Label(
                        isGenerating ? NSLocalizedString("generation.button.generating", comment: "Generating button title") : NSLocalizedString("generation.button.generate", comment: "Generate button title"),
                        systemImage: "waveform"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canGenerate)
            .opacity(canGenerate ? 1.0 : 0.4)
        }
        .padding(24)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    @Previewable @State var errorMessage: String? = nil
    @Previewable @State var audioURL: URL? = nil
    
    GenerationControlView(
        errorMessage: $errorMessage,
        lastGeneratedAudioURL: $audioURL,
        isGenerating: false,
        canGenerate: true,
        onGenerate: {},
        onCancel: {},
        onClearError: {}
    )
}
