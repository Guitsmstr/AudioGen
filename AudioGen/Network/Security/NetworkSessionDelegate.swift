import Foundation
import OSLog

/// URLSessionDelegate implementation that handles SSL pinning
final class NetworkSessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // We only care about server trust authentication
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            // For other auth methods (e.g. client cert, basic auth), use default handling
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let domain = challenge.protectionSpace.host
        
        // Validate the server trust using our pinner
        if PublicKeyPinner.validate(serverTrust: serverTrust, domain: domain) {
            // If valid, use the credential
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            // If invalid, cancel the challenge (aborts connection)
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
