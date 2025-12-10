//
//  SettingsManager.swift
//  AudioGen
//
//  Created on November 20, 2025.
//

import Foundation
import Combine
import OSLog

final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let logger = Logger(subsystem: "com.audiogen", category: "Settings")
    
    @Published var downloadsFolderURL: URL {
        didSet {
            saveDownloadsFolderURL(downloadsFolderURL)
        }
    }
    
    @Published var openAIKey: String {
        didSet {
            saveAPIKey(openAIKey)
        }
    }
    
    @Published var outputsFolderURL: URL {
        didSet {
            saveOutputsFolderURL(outputsFolderURL)
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let downloadsFolderKey = "downloadsFolderURL"
    private let openAIKeyKey = "openAIKey" // Legacy key for migration
    private let keychainAccount = "com.audiogen.openai.apikey"
    private let outputsFolderKey = "outputsFolderURL"
    
    private init() {
        // Initialize URLs first
        if let savedPath = userDefaults.string(forKey: downloadsFolderKey),
           let url = URL(string: savedPath) {
            self.downloadsFolderURL = url
        } else {
            // Default to Documents/AudioGenLibrary
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.downloadsFolderURL = documentsURL.appendingPathComponent("AudioGenLibrary", isDirectory: true)
        }
        
        // Load Outputs Folder
        if let savedPath = userDefaults.string(forKey: outputsFolderKey),
           let url = URL(string: savedPath) {
            self.outputsFolderURL = url
        } else {
            // Default to Documents/outputs
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.outputsFolderURL = documentsURL.appendingPathComponent("outputs", isDirectory: true)
        }
        
        // Initialize API key to empty first (required before calling methods)
        self.openAIKey = ""
        
        // Now load from Keychain with migration
        self.openAIKey = Self.loadAPIKeyStatic(
            userDefaults: userDefaults, 
            openAIKeyKey: openAIKeyKey, 
            keychainAccount: keychainAccount,
            logger: logger
        )
    }
    
    private func saveDownloadsFolderURL(_ url: URL) {
        userDefaults.set(url.absoluteString, forKey: downloadsFolderKey)
        
        // Also save bookmark data for security-scoped access
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            userDefaults.set(bookmarkData, forKey: "\(downloadsFolderKey)_bookmark")
        } catch {
            logger.error("Failed to create bookmark: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func saveOutputsFolderURL(_ url: URL) {
        userDefaults.set(url.absoluteString, forKey: outputsFolderKey)
        
        // Also save bookmark data for security-scoped access
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            userDefaults.set(bookmarkData, forKey: "\(outputsFolderKey)_bookmark")
        } catch {
            logger.error("Failed to create bookmark for outputs: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func resetToDefault() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        downloadsFolderURL = documentsURL.appendingPathComponent("AudioGenLibrary", isDirectory: true)
        outputsFolderURL = documentsURL.appendingPathComponent("outputs", isDirectory: true)
    }
    
    func ensureDownloadsFolderExists() throws {
        try FileManager.default.createDirectory(
            at: downloadsFolderURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
    
    func ensureOutputsFolderExists() throws {
        try FileManager.default.createDirectory(
            at: outputsFolderURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
    
    // MARK: - Keychain Helpers
    
    // Static helper to avoid self issues during init
    private static func loadAPIKeyStatic(
        userDefaults: UserDefaults,
        openAIKeyKey: String,
        keychainAccount: String,
        logger: Logger
    ) -> String {
        // First try to read from Keychain
        if let keychainKey = try? KeychainHelper.read(account: keychainAccount), !keychainKey.isEmpty {
            return keychainKey
        }
        
        // Migration: Check UserDefaults for legacy key
        if let legacyKey = userDefaults.string(forKey: openAIKeyKey), !legacyKey.isEmpty {
            logger.info("Migrating API key from UserDefaults to Keychain")
            
            // Save to Keychain
            do {
                try KeychainHelper.save(legacyKey, account: keychainAccount)
                // Remove from UserDefaults for security
                userDefaults.removeObject(forKey: openAIKeyKey)
                logger.info("Successfully migrated API key to Keychain")
                return legacyKey
            } catch {
                logger.error("Failed to migrate API key to Keychain: \(error.localizedDescription, privacy: .public)")
                // Keep in UserDefaults if migration fails
                return legacyKey
            }
        }
        
        return ""
    }
    
    private func saveAPIKey(_ key: String) {
        do {
            if key.isEmpty {
                try KeychainHelper.delete(account: keychainAccount)
            } else {
                try KeychainHelper.update(key, account: keychainAccount)
            }
        } catch {
            logger.error("Failed to save API key to Keychain: \(error.localizedDescription, privacy: .public)")
        }
    }
}
