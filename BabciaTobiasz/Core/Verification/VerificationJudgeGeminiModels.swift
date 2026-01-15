//
//  VerificationJudgeGeminiModels.swift
//  BabciaTobiasz
//
//  Gemini request/response DTOs for verification judging.
//

import Foundation

struct GeminiRequest: Encodable, Sendable {
    let contents: [GeminiRequestContent]
}

struct GeminiRequestContent: Encodable, Sendable {
    let role: String
    let parts: [GeminiRequestPart]
}

struct GeminiRequestPart: Encodable, Sendable {
    let text: String?
    let inlineData: GeminiInlineData?

    static func text(_ value: String) -> GeminiRequestPart {
        GeminiRequestPart(text: value, inlineData: nil)
    }

    static func image(base64: String, mimeType: String) -> GeminiRequestPart {
        GeminiRequestPart(text: nil, inlineData: GeminiInlineData(mimeType: mimeType, data: base64))
    }

    enum CodingKeys: String, CodingKey {
        case text
        case inlineData = "inline_data"
    }
}

struct GeminiInlineData: Encodable, Sendable {
    let mimeType: String
    let data: String

    enum CodingKeys: String, CodingKey {
        case mimeType = "mime_type"
        case data
    }
}

struct GeminiResponse: Decodable, Sendable {
    let candidates: [GeminiCandidate]?
}

struct GeminiCandidate: Decodable, Sendable {
    let content: GeminiResponseContent?
}

struct GeminiResponseContent: Decodable, Sendable {
    let parts: [GeminiResponsePart]?
}

struct GeminiResponsePart: Decodable, Sendable {
    let text: String?
}
