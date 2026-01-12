// WeatherServiceTests.swift
// BabciaTobiaszTests

import XCTest
import CoreLocation
@testable import BabciaTobiasz

final class WeatherServiceTests: XCTestCase {
    
    // MARK: - Weather DTO Tests
    
    func testWeatherResponseDTODecoding() throws {
        let json = """
        {
            "coord": {"lon": -122.4194, "lat": 37.7749},
            "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
            "main": {"temp": 20.5, "feels_like": 19.8, "temp_min": 18.0, "temp_max": 22.0, "pressure": 1013, "humidity": 65},
            "wind": {"speed": 3.5, "deg": 270},
            "dt": 1609459200,
            "sys": {"sunrise": 1609416000, "sunset": 1609452000},
            "name": "San Francisco"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let dto = try decoder.decode(WeatherResponseDTO.self, from: json)
        
        XCTAssertEqual(dto.name, "San Francisco")
        XCTAssertEqual(dto.main.temp, 20.5)
        XCTAssertEqual(dto.main.humidity, 65)
        XCTAssertEqual(dto.weather.first?.main, "Clear")
    }
    
    func testForecastResponseDTODecoding() throws {
        let json = """
        {
            "list": [
                {
                    "dt": 1609459200,
                    "main": {"temp": 20.0, "feels_like": 19.0, "temp_min": 18.0, "temp_max": 22.0, "pressure": 1013, "humidity": 60},
                    "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
                    "wind": {"speed": 3.0, "deg": 180},
                    "pop": 0.1
                }
            ],
            "city": {
                "name": "Test City",
                "coord": {"lat": 0.0, "lon": 0.0},
                "sunrise": 1609416000,
                "sunset": 1609452000
            }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let dto = try decoder.decode(ForecastResponseDTO.self, from: json)
        
        XCTAssertEqual(dto.city.name, "Test City")
        XCTAssertEqual(dto.list.count, 1)
        XCTAssertEqual(dto.list.first?.pop, 0.1)
    }
    
    // MARK: - Weather Error Tests
    
    func testWeatherErrorDescriptions() {
        XCTAssertNotNil(WeatherError.invalidURL.errorDescription)
        XCTAssertNotNil(WeatherError.invalidResponse.errorDescription)
        XCTAssertNotNil(WeatherError.httpError(statusCode: 401).errorDescription)
        XCTAssertNotNil(WeatherError.noData.errorDescription)
    }
    
    func testHTTPErrorStatusCodes() {
        let error401 = WeatherError.httpError(statusCode: 401)
        let error500 = WeatherError.httpError(statusCode: 500)
        
        XCTAssertTrue(error401.errorDescription?.contains("API key") ?? false)
        XCTAssertTrue(error500.errorDescription?.contains("HTTP 500") ?? false)
    }
}

// MARK: - WeatherData Model Tests

final class WeatherDataTests: XCTestCase {
    
    func testWeatherDataIconMapping() {
        XCTAssertEqual(WeatherData.iconName(for: "01d"), "sun.max.fill")
        XCTAssertEqual(WeatherData.iconName(for: "01n"), "moon.fill")
        XCTAssertEqual(WeatherData.iconName(for: "02d"), "cloud.sun.fill")
        XCTAssertEqual(WeatherData.iconName(for: "09d"), "cloud.drizzle.fill")
        XCTAssertEqual(WeatherData.iconName(for: "10d"), "cloud.sun.rain.fill")
        XCTAssertEqual(WeatherData.iconName(for: "11d"), "cloud.bolt.rain.fill")
        XCTAssertEqual(WeatherData.iconName(for: "13d"), "cloud.snow.fill")
        XCTAssertEqual(WeatherData.iconName(for: "50d"), "cloud.fog.fill")
    }
    
    func testWeatherDataTemperatureFormatting() {
        let weather = createTestWeatherData(temp: 25.6)
        
        XCTAssertEqual(weather.temperatureFormatted, "26°")
        XCTAssertEqual(weather.temperature, 25.6)
    }
    
    func testWeatherDataHighLowFormatting() {
        let weather = createTestWeatherData(tempMin: 18.0, tempMax: 25.0)
        
        XCTAssertTrue(weather.highLowFormatted.contains("H:"))
        XCTAssertTrue(weather.highLowFormatted.contains("L:"))
    }
    
    private func createTestWeatherData(temp: Double = 20, tempMin: Double = 18, tempMax: Double = 22) -> WeatherData {
        WeatherData(
            locationName: "Test",
            latitude: 0,
            longitude: 0,
            temperature: temp,
            feelsLike: temp,
            temperatureMin: tempMin,
            temperatureMax: tempMax,
            humidity: 50,
            windSpeed: 5,
            windDirection: 180,
            conditionCode: "01d",
            conditionDescription: "Clear",
            conditionIconName: "sun.max.fill",
            uvIndex: 5,
            visibility: 10,
            pressure: 1013,
            sunrise: Date(),
            sunset: Date().addingTimeInterval(43200)
        )
    }
}
