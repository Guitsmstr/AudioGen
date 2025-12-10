//
//  NetworkServiceProtocol.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: APIRequest>(_ request: T) async throws -> T.Response
    func requestData<T: APIRequest>(_ request: T) async throws -> Data
    func downloadData(from url: URL) async throws -> Data
    func cancelAllRequests()
}
