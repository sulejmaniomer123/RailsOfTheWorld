import Foundation
import MapKit

struct NominatimResult: Decodable {
    let displayName: String
    let lat: String
    let lon: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case lat
        case lon
    }
}

struct OverpassResponse: Decodable {
    let elements: [OverpassElement]
}

struct OverpassElement: Decodable {
    let id: Int
    let lat: Double?
    let lon: Double?
    let tags: [String: String]?
}

final class StationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let titleText: String
    let subtitleText: String?

    var title: String? { titleText }
    var subtitle: String? { subtitleText }

    init(name: String, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.titleText = name
        self.subtitleText = subtitle
        self.coordinate = coordinate
        super.init()
    }
}
