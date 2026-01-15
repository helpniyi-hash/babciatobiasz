//
//  VerificationJudgeError.swift
//  BabciaTobiasz
//
//  Error types for verification judging.
//

import Foundation

/// Errors that can occur during verification judging.
enum VerificationJudgeError: Error, LocalizedError, @unchecked Sendable {
    case apiKeyMissing
    case invalidPhotoData
    case networkFailure(underlying: Error)
    case invalidResponse(reason: String)
    case judgingFailed(reason: String)

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "Gemini API key not configured"
        case .invalidPhotoData:
            return "Photo data is invalid or empty"
        case .networkFailure(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let reason):
            return "Invalid API response: \(reason)"
        case .judgingFailed(let reason):
            return "Judging failed: \(reason)"
        }
    }
}
