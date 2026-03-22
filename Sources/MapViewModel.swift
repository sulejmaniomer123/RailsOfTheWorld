import Foundation
import MapKit
import Combine

final class MapViewModel: ObservableObject {
    @Published var mapType: MKMapType = .standard
    @Published var centerCoordinate = CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795)
    @Published var showsUserLocation = false
    @Published var railOverlayEnabled = true
    @Published var searchResults: [NominatimResult] = []
    @Published var stationAnnotations: [MKAnnotation] = []

    private var stationTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    func bindLocationManager(_ manager: LocationManager) {
        manager.$lastLocation
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self, self.showsUserLocation else { return }
                self.centerCoordinate = location.coordinate
            }
            .store(in: &cancellables)
    }

    func search(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }

        searchTask?.cancel()
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let results = try await Network.nominatimSearch(query: trimmed)
                self.searchResults = results

                if let first = results.first,
                   let lat = Double(first.lat),
                   let lon = Double(first.lon) {
                    self.centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                }
            } catch {
                self.searchResults = []
            }
        }
    }

    func selectSearchResult(_ result: NominatimResult) {
        if let lat = Double(result.lat), let lon = Double(result.lon) {
            centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }

    func requestStations(near coordinate: CLLocationCoordinate2D) {
        stationTask?.cancel()
        stationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 500_000_000)

            do {
                let elements = try await Network.overpassStations(near: coordinate, radiusMeters: 5000)
                self.stationAnnotations = elements.compactMap { element in
                    guard let lat = element.lat, let lon = element.lon else { return nil }
                    let name = element.tags?["name"] ?? "Station"
                    let line = element.tags?["railway"] ?? "railway"
                    return StationAnnotation(
                        name: name,
                        subtitle: line,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    )
                }
            } catch {
                self.stationAnnotations = []
            }
        }
    }
}
