//
//  LibraryView.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import SwiftUI
import AVKit

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with search
            headerSection
            
            Divider()
            
            // Content
            if viewModel.isLoading {
                ProgressView("Loading audio files...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.audioFiles.isEmpty {
                emptyState
            } else {
                audioList
            }
        }
        .task {
            await viewModel.loadAudioFiles()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Audio Library")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("\(viewModel.audioFiles.count) files")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .frame(width: 200)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
            
            Button(action: { Task { await viewModel.loadAudioFiles() } }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
        }
        .padding()
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Audio Files")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Generated audio files will appear here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var audioList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredAudioFiles) { audioFile in
                    AudioFileCard(audioFile: audioFile, viewModel: viewModel)
                }
            }
            .padding()
        }
    }
}

struct AudioFileCard: View {
    let audioFile: AudioFileItem
    @ObservedObject var viewModel: LibraryViewModel
    @State private var isHovering = false
    @State private var shareButtonFrame: CGRect = .zero
    
    var body: some View {
        HStack(spacing: 16) {
            // Play button with loading state
            Button(action: { viewModel.playAudio(audioFile) }) {
                if viewModel.isLoadingAudio(audioFile) {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: viewModel.isPlaying(audioFile) ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.accentColor)
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoadingAudio(audioFile))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(audioFile.fileName)
                        .font(.headline)
                    
                    if audioFile.isDownloaded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "cloud")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Text preview
                if !audioFile.text.isEmpty {
                    Text(audioFile.text)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    Label(audioFile.voice, systemImage: "person.wave.2")
                    Label(audioFile.model, systemImage: "cpu")
                    if let date = audioFile.createdDate {
                        Label(formatDate(date), systemImage: "clock")
                    }
                    Label(formatFileSize(audioFile.fileSize), systemImage: "doc")
                    if audioFile.speed != 1.0 {
                        Label(String(format: "%.1fx", audioFile.speed), systemImage: "speedometer")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if !audioFile.instructions.isEmpty {
                    Text(audioFile.instructions)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                if audioFile.isDownloaded {
                    Button(action: { viewModel.openInFinder(audioFile) }) {
                        Image(systemName: "folder")
                    }
                    .help("Open in Finder")
                    
                    ShareButton(audioFile: audioFile, viewModel: viewModel)
                        .help("Share")
                }
                
                Button(action: { viewModel.deleteAudio(audioFile) }) {
                    Image(systemName: "trash")
                }
                .help("Delete")
                .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
            .opacity(isHovering ? 1 : 0)
        }
        .padding()
        .background(isHovering ? Color(nsColor: .controlBackgroundColor) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Share Button
struct ShareButton: View {
    let audioFile: AudioFileItem
    @ObservedObject var viewModel: LibraryViewModel
    
    var body: some View {
        Button(action: {
            if let sharingPicker = viewModel.shareAudio(audioFile) {
                // Get the window and show the picker
                if let window = NSApp.keyWindow,
                   let contentView = window.contentView {
                    // Show at mouse location
                    let mouseLocation = NSEvent.mouseLocation
                    let windowLocation = window.convertPoint(fromScreen: mouseLocation)
                    let viewLocation = contentView.convert(windowLocation, from: nil)
                    
                    let rect = NSRect(x: viewLocation.x, y: viewLocation.y, width: 1, height: 1)
                    sharingPicker.show(relativeTo: rect, of: contentView, preferredEdge: .minY)
                }
            }
        }) {
            Image(systemName: "square.and.arrow.up")
        }
    }
}

#Preview {
    LibraryView()
        .frame(width: 800, height: 600)
}
