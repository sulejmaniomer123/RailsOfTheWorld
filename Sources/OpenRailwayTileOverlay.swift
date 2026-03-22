import Foundation
import MapKit

final class OpenRailwayTileOverlay: MKTileOverlay {
    private let subdomains = ["a", "b", "c"]

    override init() {
        super.init(urlTemplate: nil)
        canReplaceMapContent = false
        tileSize = CGSize(width: 256, height: 256)
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let subdomain = subdomains[(path.x + path.y) % subdomains.count]
        let urlString = "https://\(subdomain).tiles.openrailwaymap.org/standard/\(path.z)/\(path.x)/\(path.y).png"

        guard let url = URL(string: urlString) else {
            result(nil, NSError(domain: "OpenRailwayTileOverlay", code: -1))
            return
        }

        var request = URLRequest(url: url)
        request.setValue(Network.userAgent, forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            result(data, error)
        }
        task.resume()
    }
}
