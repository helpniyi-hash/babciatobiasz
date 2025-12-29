//
//  LocationService.swift
//  WeatherHabitTracker
//
//  Service responsible for handling user location permissions and updates.
//  Uses CoreLocation framework for GPS-based location tracking.
//

import Foundation
import CoreLocation

/// Service that manages location permissions and provides location updates.
/// Acts as a CLLocationManager delegate and publishes location changes.
@Observable
final class LocationService: NSObject, @unchecked Sendable {
    
    // MARK: - Published Properties
    
    /// The current user location (nil if not available)
    var currentLocation: CLLocation?
    
    /// The authorization status for location services
    var authorizationStatus: CLAuthorizationStatus
    
    /// Error message if location services fail
    var errorMessage: String?
    
    /// Whether location is currently being fetched
    var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    /// The Core Location manager
    private let locationManager: CLLocationManager
    
    /// Continuation for async location requests
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    // MARK: - Computed Properties
    
    /// Whether location services are authorized
    var isAuthorized: Bool {
        #if os(iOS)
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        #else
        return authorizationStatus == .authorizedAlways
        #endif
    }
    
    /// Human-readable location name
    var locationName: String?
    
    // MARK: - Initialization
    
    /// Initializes the location service and sets up the location manager
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000 // Update when moved 1km
    }
    
    // MARK: - Public Methods
    
    /// Requests location authorization from the user
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Requests the current location asynchronously
    /// - Returns: The current CLLocation
    /// - Throws: LocationError if location cannot be determined
    func requestLocation() async throws -> CLLocation {
        // Check if we have recent location
        if let location = currentLocation,
           Date().timeIntervalSince(location.timestamp) < 300 { // 5 minutes
            return location
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.servicesDisabled
        }
        
        switch authorizationStatus {
        case .notDetermined:
            requestAuthorization()
            // Wait for authorization
            try await Task.sleep(for: .seconds(1))
            return try await requestLocation()
            
        case .restricted, .denied:
            throw LocationError.permissionDenied
            
        case .authorizedWhenInUse, .authorizedAlways:
            break
            
        @unknown default:
            throw LocationError.unknown
        }
        
        isLoading = true
        errorMessage = nil
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
    
    /// Fetches the place name for a given location using reverse geocoding
    /// - Parameter location: The CLLocation to geocode
    /// - Returns: A human-readable place name
    func getPlaceName(for location: CLLocation) async -> String {
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""
                
                if !city.isEmpty && !state.isEmpty {
                    return "\(city), \(state)"
                } else if !city.isEmpty {
                    return "\(city), \(country)"
                } else if !state.isEmpty {
                    return "\(state), \(country)"
                } else {
                    return country
                }
            }
        } catch {
            print("Geocoding error: \(error.localizedDescription)")
        }
        
        return "Unknown Location"
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    /// Called when location authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if isAuthorized {
            errorMessage = nil
        }
    }
    
    /// Called when new locations are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        
        guard let location = locations.last else { return }
        
        currentLocation = location
        errorMessage = nil
        
        // Resume the continuation if waiting
        if let continuation = locationContinuation {
            self.locationContinuation = nil
            continuation.resume(returning: location)
        }
        
        // Update location name asynchronously
        Task {
            locationName = await getPlaceName(for: location)
        }
    }
    
    /// Called when location manager encounters an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        
        let nsError = error as NSError
        
        switch nsError.code {
        case CLError.denied.rawValue:
            errorMessage = "Location access denied. Please enable in Settings."
        case CLError.locationUnknown.rawValue:
            errorMessage = "Unable to determine location. Please try again."
        case CLError.network.rawValue:
            errorMessage = "Network error. Please check your connection."
        default:
            errorMessage = "Location error: \(error.localizedDescription)"
        }
        
        // Resume the continuation with error if waiting
        if let continuation = locationContinuation {
            self.locationContinuation = nil
            continuation.resume(throwing: LocationError.locationUnavailable(error.localizedDescription))
        }
    }
}

// MARK: - LocationError

/// Errors that can occur when fetching location
enum LocationError: LocalizedError {
    case servicesDisabled
    case permissionDenied
    case locationUnavailable(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .servicesDisabled:
            return "Location services are disabled. Please enable them in Settings."
        case .permissionDenied:
            return "Location permission denied. Please allow location access in Settings."
        case .locationUnavailable(let message):
            return "Unable to get location: \(message)"
        case .unknown:
            return "An unknown error occurred while getting location."
        }
    }
}
