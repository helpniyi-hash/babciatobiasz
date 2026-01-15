//
//  VerificationJudgeService.swift
//  BabciaTobiasz
//
//  Judges before/after photos with Gemini to verify visible cleaning progress.
//
import Foundation
/// Service that calls Gemini to judge if an after-photo is cleaner than a before-photo.
@MainActor
final class VerificationJudgeService: VerificationJudgeProtocol {
    // MARK: - Configuration
    private enum Constants {
        static let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
        static let prompt = """
You are judging a cleaning verification. Compare these two photos of the same room.

Photo 1 (BEFORE): The room before cleaning.
Photo 2 (AFTER): The room after cleaning.

Is the room VISIBLY CLEANER in the AFTER photo?

Rules:
- The room must show clear improvement (less clutter, cleaner surfaces, items put away)
- Minor changes don't count (moving one item is not enough)
- Be strict: if unsure, return false

Respond with ONLY the word "true" or "false". No explanation.
"""
        static let imageMimeType = "image/jpeg"
    }
    private let httpClient: VerificationJudgeHTTPClient
    private let apiKeyProvider: VerificationJudgeAPIKeyProvider
    private let decoder: JSONDecoder
    // MARK: - Initialization
    init(
        httpClient: VerificationJudgeHTTPClient = URLSessionHTTPClient(),
        apiKeyProvider: VerificationJudgeAPIKeyProvider = GeminiKeychainAPIKeyProvider()
    ) {
        self.httpClient = httpClient
        self.apiKeyProvider = apiKeyProvider
        self.decoder = JSONDecoder()
    }
    // MARK: - Public Methods
    /// Judges whether the after-photo shows a cleaner room than the before-photo.
    /// - Parameters:
    ///   - beforePhoto: JPEG data of the room before cleaning.
    ///   - afterPhoto: JPEG data of the room after cleaning.
    /// - Returns: `true` if room is visibly cleaner, `false` otherwise.
    /// - Throws: `VerificationJudgeError` if judging fails.
    func judge(beforePhoto: Data, afterPhoto: Data) async throws -> Bool {
        let apiKey = try loadApiKey()
        let (beforeBase64, afterBase64) = try encodePhotos(before: beforePhoto, after: afterPhoto)
        let request = try makeRequest(apiKey: apiKey, beforeBase64: beforeBase64, afterBase64: afterBase64)
        let (data, response) = try await fetchData(for: request)
        return try parseJudgement(data: data, response: response)
    }
    // MARK: - Private Helpers
    private func loadApiKey() throws -> String {
        let rawKey = apiKeyProvider.loadAPIKey()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !rawKey.isEmpty else { throw VerificationJudgeError.apiKeyMissing }
        return rawKey
    }

    private func encodePhotos(before: Data, after: Data) throws -> (String, String) {
        guard !before.isEmpty, !after.isEmpty else {
            throw VerificationJudgeError.invalidPhotoData
        }
        return (before.base64EncodedString(), after.base64EncodedString())
    }

    private func makeRequest(apiKey: String, beforeBase64: String, afterBase64: String) throws -> URLRequest {
        guard var components = URLComponents(string: Constants.endpoint) else {
            throw VerificationJudgeError.invalidResponse(reason: "Invalid endpoint URL")
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let url = components.url else {
            throw VerificationJudgeError.invalidResponse(reason: "Invalid endpoint URL")
        }

        let requestBody = GeminiRequest(contents: [
            GeminiRequestContent(role: "user", parts: [
                .text(Constants.prompt),
                .image(base64: beforeBase64, mimeType: Constants.imageMimeType),
                .image(base64: afterBase64, mimeType: Constants.imageMimeType)
            ])
        ])

        let encoder = JSONEncoder()
        let bodyData: Data
        do {
            bodyData = try encoder.encode(requestBody)
        } catch {
            throw VerificationJudgeError.invalidResponse(reason: "Encoding failed")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        return request
    }

    private func fetchData(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await httpClient.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw VerificationJudgeError.invalidResponse(reason: "Non-HTTP response")
            }
            return (data, httpResponse)
        } catch let error as VerificationJudgeError {
            throw error
        } catch {
            throw VerificationJudgeError.networkFailure(underlying: error)
        }
    }

    private func parseJudgement(data: Data, response: HTTPURLResponse) throws -> Bool {
        guard response.statusCode == 200 else {
            throw VerificationJudgeError.invalidResponse(reason: "HTTP \(response.statusCode)")
        }
        guard !data.isEmpty else {
            throw VerificationJudgeError.invalidResponse(reason: "Empty response body")
        }
        let decoded = try decodeResponse(data: data)
        guard let text = extractResponseText(from: decoded) else {
            throw VerificationJudgeError.invalidResponse(reason: "Missing response text")
        }
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized == "true" { return true }
        if normalized == "false" { return false }
        throw VerificationJudgeError.invalidResponse(reason: "Unexpected response: \(normalized)")
    }

    private func decodeResponse(data: Data) throws -> GeminiResponse {
        do {
            return try decoder.decode(GeminiResponse.self, from: data)
        } catch {
            throw VerificationJudgeError.invalidResponse(reason: "Decoding failed")
        }
    }

    private func extractResponseText(from response: GeminiResponse) -> String? {
        response.candidates?
            .first?
            .content?
            .parts?
            .compactMap { $0.text }
            .first
    }
}
