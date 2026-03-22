import Foundation
import CoreLocation

enum Network {
    // Update this with a real contact email or URL.
    static let userAgent = "RailsOfTheWorld/0.1 (you@example.com)"

    static func nominatimSearch(query: String) async throws -> [NominatimResult] {
        var components = URLComponents(string: "https://nominatim.openstreetmap.org/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "addressdetails", value: "1"),
            URLQueryItem(name: "limit", value: "10")
        ]

        guard let url = components?.url else { return [] }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([NominatimResult].self, from: data)
    }

    static func overpassStations(near coordinate: CLLocationCoordinate2D, radiusMeters: Int) async throws -> [OverpassElement] {
        let query = """
        [out:json][timeout:25];
        (
          node["railway"~"station|halt|tram_stop"](around:\(radiusMeters),\(coordinate.latitude),\(coordinate.longitude));
        );
        out body;
        """

        guard let url = URL(string: "https://overpass-api.de/api/interpreter") else { return [] }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "data=\(query)".data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(OverpassResponse.self, from: data).elements
    }
}
