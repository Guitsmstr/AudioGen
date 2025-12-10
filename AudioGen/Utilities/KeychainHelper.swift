//
//  KeychainHelper.swift
//  AudioGen
//
//  Created on December 4, 2025.
//

import Foundation
import Security

/// Secure storage utility for sensitive data using macOS Keychain
final class KeychainHelper {
    
    enum KeychainError: Error, LocalizedError {
        case invalidData
        case itemNotFound
        case duplicateItem
        case unexpectedStatus(OSStatus)
        
        var errorDescription: String? {
            switch self {
            case .invalidData:
                return "Invalid data format"
            case .itemNotFound:
                return "Item not found in Keychain"
            case .duplicateItem:
                return "Item already exists in Keychain"
            case .unexpectedStatus(let status):
                return "Keychain error: \(status)"
            }
        }
    }
    
    // MARK: - Save
    
    /// Save a string value to the Keychain
    /// - Parameters:
    ///   - value: The string to store
    ///   - account: The account identifier (e.g., "com.audiogen.openai.key")
    ///   - service: The service identifier (defaults to bundle identifier)
    static func save(_ value: String, account: String, service: String? = nil) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        let serviceID = service ?? Bundle.main.bundleIdentifier ?? "com.audiogen"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: serviceID,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Try to delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    // MARK: - Read
    
    /// Read a string value from the Keychain
    /// - Parameters:
    ///   - account: The account identifier
    ///   - service: The service identifier (defaults to bundle identifier)
    /// - Returns: The stored string, or nil if not found
    static func read(account: String, service: String? = nil) throws -> String? {
        let serviceID = service ?? Bundle.main.bundleIdentifier ?? "com.audiogen"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: serviceID,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        
        return string
    }
    
    // MARK: - Delete
    
    /// Delete a value from the Keychain
    /// - Parameters:
    ///   - account: The account identifier
    ///   - service: The service identifier (defaults to bundle identifier)
    static func delete(account: String, service: String? = nil) throws {
        let serviceID = service ?? Bundle.main.bundleIdentifier ?? "com.audiogen"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: serviceID
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    // MARK: - Update
    
    /// Update an existing Keychain item
    /// - Parameters:
    ///   - value: The new string value
    ///   - account: The account identifier
    ///   - service: The service identifier (defaults to bundle identifier)
    static func update(_ value: String, account: String, service: String? = nil) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        let serviceID = service ?? Bundle.main.bundleIdentifier ?? "com.audiogen"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: serviceID
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecItemNotFound {
            // Item doesn't exist, save it instead
            try save(value, account: account, service: service)
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
