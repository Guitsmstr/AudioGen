//
//  AudioGenerationViewModel.swift
//  AudioGen
//
//  Created by Guillermo Vertel on 19/11/25.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for managing audio generation state and business logic
@MainActor
final class AudioGenerationViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published var textInput: String = "" {
        didSet {
            if textInput.count > AppConfig.Limits.maxInputLength {
                textInput = String(textInput.prefix(AppConfig.Limits.maxInputLength))
            }
        }
    }
    @Published var instructions: String = "" {
        didSet {
            if instructions.count > AppConfig.Limits.maxInstructionsLength {
                instructions = String(instructions.prefix(AppConfig.Limits.maxInstructionsLength))
            }
        }
    }
    @Published var selectedVoice: Voice = .default
    @Published var availableVoices: [Voice] = Voice.availableVoices
    
    // Loading states
    @Published var isLoadingVoices: Bool = false
    @Published var isGenerating: Bool = false
    @Published var isDownloading: Bool = false
    
    // Error states
    @Published var errorMessage: String?
    @Published var voiceLoadError: String?
    
    // Generation result
    @Published var lastGeneratedAudioURL: URL?
    @Published var generationProgress: String = ""
    
    // MARK: - Dependencies
    
    private let voiceRepository: VoiceRepositoryProtocol
    private let audioRepository: AudioRepositoryProtocol
    
    // MARK: - Constants
    
    // Constants moved to AppConfig
    
    // MARK: - Computed Properties
    
    var canGenerate: Bool {
        !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
        && !isGenerating 
        && !SettingsManager.shared.openAIKey.isEmpty
    }
    
    var characterCount: Int {
        textInput.count
    }
    
    var isNearCharacterLimit: Bool {
        characterCount > AppConfig.Limits.warningThreshold
    }
    
    var isAtCharacterLimit: Bool {
        characterCount >= AppConfig.Limits.maxInputLength
    }
    
    // MARK: - Initialization
    
    init(
        voiceRepository: VoiceRepositoryProtocol,
        audioRepository: AudioRepositoryProtocol
    ) {
        self.voiceRepository = voiceRepository
        self.audioRepository = audioRepository
        
        // We no longer check server health on init as we use OpenAI directly
        // But we can still load voices if we implement OpenAI voice fetching later
        // For now, we rely on static voices or whatever VoiceRepository does
        Task {
            await loadVoices()
        }
    }
    
    // Convenience initializer for production
    convenience init() {
        let networkService = NetworkService()
        let voiceRepo = VoiceRepository()
        let audioRepo = AudioRepository(networkService: networkService)
        self.init(voiceRepository: voiceRepo, audioRepository: audioRepo)
    }
    
    // MARK: - Voice Loading
    
    func loadVoices(forceFresh: Bool = false) async {
        isLoadingVoices = true
        voiceLoadError = nil
        
        // For now, we might want to just use static voices if we haven't migrated VoiceRepository
        // But let's keep the call and handle failure gracefully
        let result = await voiceRepository.fetchVoices(forceFresh: forceFresh)
        
        switch result {
        case .success(let voices):
            availableVoices = voices
            if selectedVoice.id.isEmpty || !voices.contains(where: { $0.id == selectedVoice.id }) {
                selectedVoice = voices.first ?? .default
            }
        case .failure:
            // Just log error and use static voices, don't block UI
            // Note: Avoiding logging error details to prevent exposing sensitive information
            availableVoices = Voice.availableVoices
            if selectedVoice.id.isEmpty {
                selectedVoice = .default
            }
        }
        
        isLoadingVoices = false
    }
    
    // MARK: - Actions
    
    func generateAudio() {
        guard canGenerate else { return }
        
        let config = AudioGenerationConfig(
            input: textInput,
            voice: selectedVoice,
            instructions: instructions.isEmpty ? nil : instructions
        )
        
        // Validate configuration
        switch config.validate() {
        case .success:
            errorMessage = nil
            Task {
                await performGeneration(with: config)
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    private func performGeneration(with config: AudioGenerationConfig) async {
        isGenerating = true
        errorMessage = nil
        generationProgress = NSLocalizedString("generation.progress.generating", comment: "Generation progress message")
        lastGeneratedAudioURL = nil
        
        // Generate audio
        let result = await audioRepository.generateAudio(config: config)
        
        isGenerating = false
        generationProgress = ""
        
        switch result {
        case .success(let fileEntry):
            // Construct full URL from FileEntry
            let outputsFolder = SettingsManager.shared.outputsFolderURL
            let fullURL = fileEntry.url(relativeTo: outputsFolder)
            lastGeneratedAudioURL = fullURL
            errorMessage = nil
            
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func retryLoadVoices() {
        Task {
            await loadVoices()
        }
    }
    
    func cancelGeneration() {
        audioRepository.cancelGeneration()
        isGenerating = false
        isDownloading = false
        generationProgress = ""
    }
    
    func clearError() {
        errorMessage = nil
        voiceLoadError = nil
    }
}
