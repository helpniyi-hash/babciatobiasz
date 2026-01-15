//
//  VerificationJudgeProtocol.swift
//  BabciaTobiasz
//
//  Protocol for photo verification judging.
//

import Foundation

/// Protocol for services that judge before/after photo verification.
@MainActor
protocol VerificationJudgeProtocol: Sendable {
    /// Judges whether the after-photo shows a cleaner room than the before-photo.
    /// - Parameters:
    ///   - beforePhoto: JPEG data of the room before cleaning.
    ///   - afterPhoto: JPEG data of the room after cleaning.
    /// - Returns: `true` if room is visibly cleaner, `false` otherwise.
    /// - Throws: `VerificationJudgeError` if judging fails.
    func judge(beforePhoto: Data, afterPhoto: Data) async throws -> Bool
}
