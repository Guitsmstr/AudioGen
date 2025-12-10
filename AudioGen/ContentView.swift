//
//  ContentView.swift
//  AudioGen
//
//  Created by Guillermo Vertel on 18/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AudioGenerationViewModel()
    @State private var isInstructionsExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
            
            // Voice Loading Error
            if let voiceError = viewModel.voiceLoadError {
                HStack {
                    Image(systemName: "wifi.exclamationmark")
                        .foregroundColor(.orange)
                    Text(voiceError)
                        .font(.callout)
                    Spacer()
                    Button(NSLocalizedString("common.dismiss", comment: "Dismiss button title")) {
                        viewModel.clearError()
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Voice Settings
            VoicePickerView(
                voices: viewModel.availableVoices,
                selectedVoice: $viewModel.selectedVoice,
                isLoading: viewModel.isLoadingVoices
            )
            
            // Content & Instructions
            TextInputView(
                text: $viewModel.textInput,
                instructions: $viewModel.instructions,
                isInstructionsExpanded: $isInstructionsExpanded,
                characterCount: viewModel.characterCount,
                isAtCharacterLimit: viewModel.isAtCharacterLimit,
                isNearCharacterLimit: viewModel.isNearCharacterLimit
            )
            
                }
                .padding(24)
            }
            .onChange(of: isInstructionsExpanded) { expanded in
                if expanded {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo("instructions", anchor: .center)
                        }
                    }
                }
            }
            }
            
            Divider()
            
            // Bottom Section
            GenerationControlView(
                errorMessage: $viewModel.errorMessage,
                lastGeneratedAudioURL: $viewModel.lastGeneratedAudioURL,
                isGenerating: viewModel.isGenerating,
                canGenerate: viewModel.canGenerate,
                onGenerate: viewModel.generateAudio,
                onCancel: viewModel.cancelGeneration,
                onClearError: viewModel.clearError
            )
        }
        .frame(minWidth: 600, minHeight: 500)
    }
}

#Preview {
    ContentView()
}
