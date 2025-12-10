//
//  LibraryViewModel.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

struct AudioFileItem: Identifiable, Equatable {
    let id: String // Now using server-provided ID
    let fileName: String
    let filePath: String // Remote path on server
    let text: String // Preview text
    let fullText: String // Full text content
    let voice: String
    let model: String
    let duration: String
    let fileSize: Int
    let instructions: String
    let speed: Double
    let format: String
    let configHash: String
    let createdAt: String
    var localURL: URL? // Local file URL if downloaded - mutable to allow updates
    
    var isDownloaded: Bool {
        guard let localURL = localURL else { return false }
        return FileManager.default.fileExists(atPath: localURL.path)
    }
    
    var createdDate: Date? {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: createdAt) {
            return date
        }
        
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt)
    }
    
    static func == (lhs: AudioFileItem, rhs: AudioFileItem) -> Bool {
        lhs.id == rhs.id && lhs.localURL == rhs.localURL
    }
}

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var audioFiles: [AudioFileItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var downloadingFiles: Set<String> = []
    @Published var loadingAudioFiles: Set<String> = []
    @Published private var currentlyPlaying: String?
    
    private let networkService: NetworkServiceProtocol
    private let audioRepository: AudioRepositoryProtocol
    private let settings = SettingsManager.shared
    private var audioPlayer: AVAudioPlayer?
    
    init(networkService: NetworkServiceProtocol = NetworkService(), audioRepository: AudioRepositoryProtocol? = nil) {
        self.networkService = networkService
        self.audioRepository = audioRepository ?? AudioRepository(networkService: networkService)
    }
    
    var filteredAudioFiles: [AudioFileItem] {
        guard !searchQuery.isEmpty else { return audioFiles }
        return audioFiles.filter { file in
            file.fileName.localizedCaseInsensitiveContains(searchQuery) ||
            file.voice.localizedCaseInsensitiveContains(searchQuery) ||
            file.text.localizedCaseInsensitiveContains(searchQuery) ||
            file.instructions.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    func loadAudioFiles() async {
        isLoading = true
        errorMessage = nil
        
        let indexURL = settings.outputsFolderURL.appendingPathComponent("index.json")
        
        guard FileManager.default.fileExists(atPath: indexURL.path) else {
            audioFiles = []
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: indexURL)
            let indexFile = try JSONDecoder().decode(IndexFile.self, from: data)
            
            // Convert FileEntry to AudioFileItem
            let files = indexFile.files.map { entry -> AudioFileItem in
                let fullURL = entry.url(relativeTo: settings.outputsFolderURL)
                
                // Calculate file size if possible
                let fileSize = (try? FileManager.default.attributesOfItem(atPath: fullURL.path)[.size] as? Int) ?? 0
                
                return AudioFileItem(
                    id: entry.id,
                    fileName: entry.filename,
                    filePath: entry.path,
                    text: entry.text,
                    fullText: entry.text,
                    voice: entry.voice,
                    model: entry.model,
                    duration: "Unknown",
                    fileSize: fileSize,
                    instructions: entry.instructions ?? "",
                    speed: entry.speed,
                    format: (entry.filename as NSString).pathExtension,
                    configHash: "",
                    createdAt: ISO8601DateFormatter().string(from: entry.timestamp),
                    localURL: fullURL
                )
            }
            
            // Sort by date descending
            audioFiles = files.sorted(by: { ($0.createdDate ?? Date()) > ($1.createdDate ?? Date()) })
            
        } catch {
            errorMessage = "Failed to load library: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refreshDownloadedStatus() {
        // No-op in local mode
    }
    
    private func getLocalURL(for fileName: String) -> URL? {
        let localURL = settings.downloadsFolderURL.appendingPathComponent(fileName)
        
        // Always check if file exists before returning
        guard FileManager.default.fileExists(atPath: localURL.path) else {
            return nil
        }
        
        return localURL
    }
    
    func isDownloading(_ audioFile: AudioFileItem) -> Bool {
        downloadingFiles.contains(audioFile.id)
    }
    
    func isLoadingAudio(_ audioFile: AudioFileItem) -> Bool {
        loadingAudioFiles.contains(audioFile.id)
    }
    
    // Note: In local-only mode, files are already available at localURL
    // No download needed
    
    func isPlaying(_ audioFile: AudioFileItem) -> Bool {
        currentlyPlaying == audioFile.filePath && audioPlayer?.isPlaying == true
    }
    
    func playAudio(_ audioFile: AudioFileItem) {
        // If already playing this file, pause it
        if isPlaying(audioFile) {
            audioPlayer?.pause()
            currentlyPlaying = nil
            return
        }
        
        // Don't start playing if already loading this file
        guard !loadingAudioFiles.contains(audioFile.id) else {
            return
        }
        
        Task {
            // Mark as loading (shows spinner in UI)
            loadingAudioFiles.insert(audioFile.id)
            
            do {
                // Use local file only
                guard let localURL = audioFile.localURL else {
                    errorMessage = "File not found locally"
                    loadingAudioFiles.remove(audioFile.id)
                    return
                }
                
                // Play audio from local location
                audioPlayer = try AVAudioPlayer(contentsOf: localURL)
                audioPlayer?.play()
                currentlyPlaying = audioFile.filePath
                
                // Remove loading state after playback starts
                loadingAudioFiles.remove(audioFile.id)
                
            } catch {
                loadingAudioFiles.remove(audioFile.id)
                errorMessage = "Failed to play audio: \(error.localizedDescription)"
            }
        }
    }
    
    func openInFinder(_ audioFile: AudioFileItem) {
        guard audioFile.isDownloaded, let localURL = audioFile.localURL else {
            errorMessage = "File not downloaded yet"
            return
        }
        
        // Open in Finder
        NSWorkspace.shared.selectFile(localURL.path, inFileViewerRootedAtPath: localURL.deletingLastPathComponent().path)
    }
    
    func shareAudio(_ audioFile: AudioFileItem) -> NSSharingServicePicker? {
        guard audioFile.isDownloaded, let localURL = audioFile.localURL else {
            errorMessage = "File not downloaded yet"
            return nil
        }
        
        // Create sharing service picker
        let sharingService = NSSharingServicePicker(items: [localURL])
        return sharingService
    }
    
    func deleteAudio(_ audioFile: AudioFileItem) {
        // Delete physical file
        if let localURL = audioFile.localURL {
            do {
                try FileManager.default.removeItem(at: localURL)
            } catch {
                errorMessage = "Failed to delete file: \(error.localizedDescription)"
                return
            }
        }
        
        // Update index.json
        let indexURL = settings.outputsFolderURL.appendingPathComponent("index.json")
        
        do {
            if FileManager.default.fileExists(atPath: indexURL.path) {
                let data = try Data(contentsOf: indexURL)
                var indexFile = try JSONDecoder().decode(IndexFile.self, from: data)
                
                // Remove entry from index
                indexFile.files.removeAll { $0.id == audioFile.id }
                
                // Save updated index
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let updatedData = try encoder.encode(indexFile)
                try updatedData.write(to: indexURL)
            }
        } catch {
            errorMessage = "Failed to update index: \(error.localizedDescription)"
            return
        }
        
        // Remove from UI list
        audioFiles.removeAll { $0.id == audioFile.id }
    }
}
