import Foundation
import Security
import CommonCrypto
import OSLog

/// Handles Public Key Pinning validation for network requests.
/// This ensures that we are connecting to the expected server by verifying
/// the hash of the server's public key against a list of known trusted keys.
final class PublicKeyPinner {
    private static let logger = Logger(subsystem: "com.audiogen", category: "Security")
    
    // Map of domain to array of valid public key hashes (Base64 encoded SHA256)
    // We use an array to support key rotation (current + backup)
    private static let pinnedKeys: [String: [String]] = [
        "api.openai.com": [
            // RSA Key (PKCS#1) - This is what SecKeyCopyExternalRepresentation returns for RSA keys
            "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=",
            // SPKI - Standard OpenSSL output (keeping as backup/alternative)
            "5KjN64rxTiC13wacHTGCLnBdD2k6jwPdd7duayEkNiU=",
            // Actual runtime hash observed in logs
            "60/iaDN1LE6KKGxaEtLRcUM4Fr31/v6X7LkAyIAjht8="
        ]
    ]
    
    /// Validates the server trust against pinned keys
    /// - Parameters:
    ///   - serverTrust: The server trust object from the authentication challenge
    ///   - domain: The domain being accessed
    /// - Returns: True if the connection should be allowed, False otherwise
    static func validate(serverTrust: SecTrust, domain: String?) -> Bool {
        guard let domain = domain else { return true }
        
        // 1. Check if we have pins for this domain
        guard let validHashes = pinnedKeys[domain] else {
            // If domain is not pinned, we default to allowing it (standard SSL only)
            // This allows the app to talk to other services if needed without pinning
            return true
        }
        
        // 2. Validate the trust chain first (standard SSL check)
        var error: CFError?
        let isTrusted = SecTrustEvaluateWithError(serverTrust, &error)
        if !isTrusted {
            logger.error("❌ Standard SSL validation failed for \(domain): \(error?.localizedDescription ?? "Unknown error")")
            return false
        }
        
        // 3. Extract public key from leaf certificate
        guard let chain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let certificate = chain.first,
              let publicKey = SecCertificateCopyKey(certificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            logger.error("❌ Failed to extract public key for domain: \(domain)")
            return false
        }
        
        // 4. Hash the key
        let keyHash = sha256(data: publicKeyData)
        
        // 5. Compare
        if validHashes.contains(keyHash) {
            logger.debug("✅ Public key pinning success for \(domain)")
            return true
        }
        
        logger.error("⛔️ Public key pinning failure for \(domain).")
        logger.error("   Expected: \(validHashes)")
        logger.error("   Received: \(keyHash)")
        
        return false
    }
    
    private static func sha256(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
}
