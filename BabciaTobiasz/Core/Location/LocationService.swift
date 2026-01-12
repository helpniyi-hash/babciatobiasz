// LocationService.swift
// BabciaTobiasz

import Foundation
import CoreLocation
import MapKit

@Observable
final class LocationService: NSObject, @unchecked Sendable {
    
    // MARK: - State
    
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus
    var errorMessage: String?
    var isLoading: Bool = false
    var locationName: String?
    var completions: [LocationCompletion] = []
    
    // MARK: - Private Properties
    
    private let locationManager: CLLocationManager
    private let searchCompleter = MKLocalSearchCompleter()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    // MARK: - Computed Properties
    
    var isAuthorized: Bool {
        #if os(iOS)
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        #else
        return authorizationStatus == .authorizedAlways
        #endif
    }
    
    // MARK: - Initialization
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000
        
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    // MARK: - Public Methods
    
    func updateSearchQuery(_ query: String) {
        searchCompleter.queryFragment = query
    }
    
    func resolveLocation(from completion: LocationCompletion) async throws -> LocationSearchResult {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "\(completion.title) \(completion.subtitle)"
        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()
        
        guard let item = response.mapItems.first,
              let location = item.placemark.location else {
            throw LocationError.locationUnavailable("Location not found")
        }
        
        return LocationSearchResult(
            id: UUID(),
            name: completion.title,
            location: location
        )
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() async throws -> CLLocation {
        // Return cached location if recent (5 min)
        if let location = currentLocation,
           Date().timeIntervalSince(location.timestamp) < 300 {
            return location
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.servicesDisabled
        }
        
        switch authorizationStatus {
        case .notDetermined:
            requestAuthorization()
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
    
    func searchLocation(query: String) async throws -> [LocationSearchResult] {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(query)
        
        return placemarks.compactMap { placemark in
            guard let location = placemark.location,
                  let name = placemark.name ?? placemark.locality else { return nil }
            
            var title = name
            if let locality = placemark.locality, locality != name {
                title += ", \(locality)"
            }
            if let administrativeArea = placemark.administrativeArea {
                title += ", \(administrativeArea)"
            }
            if let country = placemark.country {
                title += ", \(country)"
            }
            
            return LocationSearchResult(
                id: UUID(),
                name: title,
                location: location
            )
        }
    }
}

struct LocationSearchResult: Identifiable, Sendable {
    let id: UUID
    let name: String
    let location: CLLocation
}

struct LocationCompletion: Identifiable, Hashable, Sendable {
    let id = UUID()
    let title: String
    let subtitle: String
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.map { result in
            LocationCompletion(title: result.title, subtitle: result.subtitle)
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isAuthorized { errorMessage = nil }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        guard let location = locations.last else { return }
        
        currentLocation = location
        errorMessage = nil
        
        if let continuation = locationContinuation {
            self.locationContinuation = nil
            continuation.resume(returning: location)
        }
        
        Task { locationName = await getPlaceName(for: location) }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        let nsError = error as NSError
        
        switch nsError.code {
        case CLError.denied.rawValue:
            errorMessage = "Location access denied."
        case CLError.locationUnknown.rawValue:
            errorMessage = "Unable to determine location."
        case CLError.network.rawValue:
            errorMessage = "Network error."
        default:
            errorMessage = "Location error: \(error.localizedDescription)"
        }
        
        if let continuation = locationContinuation {
            self.locationContinuation = nil
            continuation.resume(throwing: LocationError.locationUnavailable(error.localizedDescription))
        }
    }
}

// MARK: - LocationError

enum LocationError: LocalizedError {
    case servicesDisabled
    case permissionDenied
    case locationUnavailable(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .servicesDisabled: return "Location services disabled."
        case .permissionDenied: return "Location permission denied."
        case .locationUnavailable(let message): return "Location unavailable: \(message)"
        case .unknown: return "Unknown location error."
        }
    }
}
