// WeatherViewModelTests.swift
// WeatherHabitTrackerTests

import XCTest
@testable import WeatherHabitTracker

@MainActor
final class WeatherViewModelTests: XCTestCase {
    var sut: WeatherViewModel!
    var mockService: MockWeatherService!
    
    override func setUp() async throws {
        mockService = MockWeatherService()
        sut = WeatherViewModel(weatherService: mockService)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockService = nil
    }
    
    // MARK: - Fetch Weather Tests
    
    func testFetchWeatherSuccess() async {
        let expectedTemp = 25.0
        await mockService.setMockWeather(WeatherResponseDTO(
            coord: CoordDTO(lon: 0, lat: 0),
            weather: [WeatherConditionDTO(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            main: MainWeatherDTO(temp: expectedTemp, feelsLike: 26.0, tempMin: 20.0, tempMax: 30.0, pressure: 1013, humidity: 50),
            wind: WindDTO(speed: 5.0, deg: 180),
            dt: Date().timeIntervalSince1970,
            sys: SysDTO(sunrise: Date().timeIntervalSince1970, sunset: Date().timeIntervalSince1970 + 3600),
            name: "Test City"
        ))
        
        await sut.refresh()
        
        XCTAssertNotNil(sut.currentWeather)
        XCTAssertEqual(sut.currentWeather?.temperature, expectedTemp)
        XCTAssertEqual(sut.currentWeather?.locationName, "Test City")
    }
    
    func testFetchWeatherFailure() async {
        await mockService.setShouldFail(true)
        await sut.refresh()
        XCTAssertTrue(sut.showError)
    }
    
    func testBackgroundColorsForClearDay() async {
        await mockService.setMockWeather(createMockWeatherDTO(icon: "01d"))
        await sut.refresh()
        XCTAssertFalse(sut.backgroundColors.isEmpty)
    }
    
    func testNeedsRefreshWhenNoData() {
        XCTAssertTrue(sut.needsRefresh)
    }
    
    func testDismissError() async {
        await mockService.setShouldFail(true)
        await sut.refresh()
        sut.dismissError()
        XCTAssertFalse(sut.showError)
    }
    
    // MARK: - Helper
    
    private func createMockWeatherDTO(icon: String) -> WeatherResponseDTO {
        WeatherResponseDTO(
            coord: CoordDTO(lon: 0, lat: 0),
            weather: [WeatherConditionDTO(id: 800, main: "Clear", description: "clear", icon: icon)],
            main: MainWeatherDTO(temp: 20, feelsLike: 20, tempMin: 18, tempMax: 22, pressure: 1013, humidity: 50),
            wind: WindDTO(speed: 5.0, deg: 180),
            dt: Date().timeIntervalSince1970,
            sys: SysDTO(sunrise: Date().timeIntervalSince1970, sunset: Date().timeIntervalSince1970 + 43200),
            name: "Mock City"
        )
    }
}

// MARK: - Mock Weather Service

actor MockWeatherService: WeatherServiceProtocol {
    private var mockWeather: WeatherResponseDTO?
    private var mockForecast: ForecastResponseDTO?
    private var shouldFail = false
    
    func setMockWeather(_ weather: WeatherResponseDTO) { mockWeather = weather }
    func setMockForecast(_ forecast: ForecastResponseDTO) { mockForecast = forecast }
    func setShouldFail(_ fail: Bool) { shouldFail = fail }
    
    func fetchCurrentWeather() async throws -> WeatherResponseDTO {
        if shouldFail { throw URLError(.badServerResponse) }
        return mockWeather ?? defaultWeatherDTO()
    }
    
    func fetchForecast() async throws -> ForecastResponseDTO {
        if shouldFail { throw URLError(.badServerResponse) }
        return mockForecast ?? ForecastResponseDTO(list: [], city: CityDTO(name: "Mock", coord: CoordDTO(lon: 0, lat: 0), sunrise: 0, sunset: 0))
    }
    
    private func defaultWeatherDTO() -> WeatherResponseDTO {
        WeatherResponseDTO(
            coord: CoordDTO(lon: 0, lat: 0),
            weather: [],
            main: MainWeatherDTO(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0),
            wind: WindDTO(speed: 0, deg: 0),
            dt: 0,
            sys: SysDTO(sunrise: 0, sunset: 0),
            name: "Mock"
        )
    }
}
