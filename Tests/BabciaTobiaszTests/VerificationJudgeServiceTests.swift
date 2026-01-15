// VerificationJudgeServiceTests.swift
// BabciaTobiaszTests
import XCTest
@testable import BabciaTobiasz
@MainActor
final class VerificationJudgeServiceTests: XCTestCase {
    func testJudge_whenApiKeyMissing_throwsApiKeyMissing() async {
        let httpClient = MockVerificationJudgeHTTPClient()
        let sut = VerificationJudgeService(
            httpClient: httpClient,
            apiKeyProvider: StubAPIKeyProvider(key: nil)
        )

        do {
            _ = try await sut.judge(beforePhoto: Data([0x01]), afterPhoto: Data([0x02]))
            XCTFail("Expected apiKeyMissing to be thrown")
        } catch let error as VerificationJudgeError {
            guard case .apiKeyMissing = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    func testJudge_whenBeforePhotoEmpty_throwsInvalidPhotoData() async {
        let httpClient = MockVerificationJudgeHTTPClient()
        let sut = VerificationJudgeService(
            httpClient: httpClient,
            apiKeyProvider: StubAPIKeyProvider(key: "test-key")
        )

        do {
            _ = try await sut.judge(beforePhoto: Data(), afterPhoto: Data([0x02]))
            XCTFail("Expected invalidPhotoData to be thrown")
        } catch let error as VerificationJudgeError {
            guard case .invalidPhotoData = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    func testJudge_whenAfterPhotoEmpty_throwsInvalidPhotoData() async {
        let httpClient = MockVerificationJudgeHTTPClient()
        let sut = VerificationJudgeService(
            httpClient: httpClient,
            apiKeyProvider: StubAPIKeyProvider(key: "test-key")
        )

        do {
            _ = try await sut.judge(beforePhoto: Data([0x01]), afterPhoto: Data())
            XCTFail("Expected invalidPhotoData to be thrown")
        } catch let error as VerificationJudgeError {
            guard case .invalidPhotoData = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    func testJudge_whenApiReturnsTrue_returnsTrue() async throws {
        let httpClient = MockVerificationJudgeHTTPClient()
        httpClient.nextResult = .success(makeHTTPResult(text: "true"))
        let sut = VerificationJudgeService(
            httpClient: httpClient,
            apiKeyProvider: StubAPIKeyProvider(key: "test-key")
        )

        let result = try await sut.judge(beforePhoto: Data([0x01]), afterPhoto: Data([0x02]))

        XCTAssertTrue(result)
    }
    func testJudge_whenApiReturnsFalse_returnsFalse() async throws {
        let httpClient = MockVerificationJudgeHTTPClient()
        httpClient.nextResult = .success(makeHTTPResult(text: "false"))
        let sut = VerificationJudgeService(
            httpClient: httpClient,
            apiKeyProvider: StubAPIKeyProvider(key: "test-key")
        )

        let result = try await sut.judge(beforePhoto: Data([0x01]), afterPhoto: Data([0x02]))

        XCTAssertFalse(result)
    }
    func testJudge_whenApiReturnsGarbage_throwsInvalidResponse() async {
        let httpClient = MockVerificationJudgeHTTPClient()
        httpClient.nextResult = .success(makeHTTPResult(text: "maybe"))
        let sut = VerificationJudgeService(
            httpClient: httpClient,
            apiKeyProvider: StubAPIKeyProvider(key: "test-key")
        )

        do {
            _ = try await sut.judge(beforePhoto: Data([0x01]), afterPhoto: Data([0x02]))
            XCTFail("Expected invalidResponse to be thrown")
        } catch let error as VerificationJudgeError {
            guard case .invalidResponse = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    private func makeHTTPResult(text: String) -> (Data, URLResponse) {
        let payload = """
        {"candidates":[{"content":{"parts":[{"text":"\(text)"}]}}]}
        """
        let data = Data(payload.utf8)
        guard let url = URL(string: "https://example.com"),
              let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ) else {
            return (data, URLResponse())
        }
        return (data, response)
    }
}

private final class MockVerificationJudgeHTTPClient: VerificationJudgeHTTPClient {
    var nextResult: Result<(Data, URLResponse), Error> = .failure(MockHTTPError.unset)

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        switch nextResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
}

private struct StubAPIKeyProvider: VerificationJudgeAPIKeyProvider {
    let key: String?

    func loadAPIKey() -> String? {
        key
    }
}

private enum MockHTTPError: Error {
    case unset
}
