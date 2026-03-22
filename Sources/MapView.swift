import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
    @Binding var mapType: MKMapType
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var showsUserLocation: Bool
    @Binding var railOverlayEnabled: Bool

    var stationAnnotations: [MKAnnotation]
    var onCenterChanged: (CLLocationCoordinate2D) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        mapView.showsUserLocation = showsUserLocation
        mapView.pointOfInterestFilter = .excludingAll

        let overlay = OpenRailwayTileOverlay()
        context.coordinator.railOverlay = overlay
        mapView.addOverlay(overlay, level: .aboveRoads)

        return mapView
    }

    func updateNSView(_ mapView: MKMapView, context: Context) {
        if mapView.mapType != mapType {
            mapView.mapType = mapType
        }

        if mapView.showsUserLocation != showsUserLocation {
            mapView.showsUserLocation = showsUserLocation
        }

        let currentCenter = mapView.centerCoordinate
        if currentCenter.isValidDistance(from: centerCoordinate, thresholdMeters: 60) {
            let region = MKCoordinateRegion(center: centerCoordinate, span: mapView.region.span)
            mapView.setRegion(region, animated: true)
        }

        if railOverlayEnabled {
            if let overlay = context.coordinator.railOverlay,
               !mapView.overlays.contains(where: { $0 === overlay }) {
                mapView.addOverlay(overlay, level: .aboveRoads)
            }
        } else {
            if let overlay = context.coordinator.railOverlay,
               mapView.overlays.contains(where: { $0 === overlay }) {
                mapView.removeOverlay(overlay)
            }
        }

        context.coordinator.updateAnnotations(on: mapView, newAnnotations: stationAnnotations)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        private var parent: MapView
        var railOverlay: OpenRailwayTileOverlay?
        private var currentAnnotations: [MKAnnotation] = []

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let center = mapView.centerCoordinate
            parent.centerCoordinate = center
            parent.onCenterChanged(center)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tileOverlay = overlay as? MKTileOverlay {
                return MKTileOverlayRenderer(tileOverlay: tileOverlay)
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func updateAnnotations(on mapView: MKMapView, newAnnotations: [MKAnnotation]) {
            let toRemove = currentAnnotations.filter { annotation in
                !newAnnotations.contains(where: { $0 === annotation })
            }
            let toAdd = newAnnotations.filter { annotation in
                !currentAnnotations.contains(where: { $0 === annotation })
            }

            if !toRemove.isEmpty {
                mapView.removeAnnotations(toRemove)
            }
            if !toAdd.isEmpty {
                mapView.addAnnotations(toAdd)
            }
            currentAnnotations = newAnnotations
        }
    }
}

private extension CLLocationCoordinate2D {
    func isValidDistance(from other: CLLocationCoordinate2D, thresholdMeters: CLLocationDistance) -> Bool {
        let a = CLLocation(latitude: latitude, longitude: longitude)
        let b = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return a.distance(from: b) > thresholdMeters
    }
}
