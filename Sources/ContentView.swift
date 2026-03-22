import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()

    @State private var searchText = ""
    @State private var colorSchemeOverride: ColorScheme? = nil

    var body: some View {
        VStack(spacing: 0) {
            controlBar
            Divider()
            MapView(
                mapType: $viewModel.mapType,
                centerCoordinate: $viewModel.centerCoordinate,
                showsUserLocation: $viewModel.showsUserLocation,
                railOverlayEnabled: $viewModel.railOverlayEnabled,
                stationAnnotations: viewModel.stationAnnotations,
                onCenterChanged: { center in
                    viewModel.requestStations(near: center)
                }
            )
            .environment(\.colorScheme, colorSchemeOverride)
            .overlay(alignment: .topLeading) {
                searchResultsPanel
            }
            attributionBar
        }
        .frame(minWidth: 900, minHeight: 650)
        .onAppear {
            locationManager.requestPermission()
            viewModel.bindLocationManager(locationManager)
        }
    }

    private var searchResultsPanel: some View {
        Group {
            if !viewModel.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Search Results")
                        .font(.headline)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(viewModel.searchResults.indices, id: \\.self) { index in
                                let result = viewModel.searchResults[index]
                                Button(result.displayName) {
                                    viewModel.selectSearchResult(result)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .frame(maxHeight: 220)
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding(12)
                .frame(maxWidth: 360, alignment: .leading)
            }
        }
    }

    private var controlBar: some View {
        HStack(spacing: 12) {
            TextField("Search places or stations", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 260)
                .onSubmit {
                    viewModel.search(query: searchText)
                }

            Button("Search") {
                viewModel.search(query: searchText)
            }

            Divider().frame(height: 20)

            Picker("Map", selection: $viewModel.mapType) {
                Text("Standard").tag(MKMapType.standard)
                Text("Satellite").tag(MKMapType.satellite)
                Text("Hybrid").tag(MKMapType.hybrid)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 240)

            Toggle("Railways", isOn: $viewModel.railOverlayEnabled)
                .toggleStyle(SwitchToggleStyle())

            Toggle("GPS", isOn: $viewModel.showsUserLocation)
                .toggleStyle(SwitchToggleStyle())

            Divider().frame(height: 20)

            Picker("Appearance", selection: $colorSchemeOverride) {
                Text("Auto").tag(ColorScheme?.none)
                Text("Light").tag(ColorScheme?.some(.light))
                Text("Dark").tag(ColorScheme?.some(.dark))
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 220)

            Spacer()
        }
        .padding(10)
    }

    private var attributionBar: some View {
        HStack {
            Text("Map data © OpenStreetMap contributors, OpenRailwayMap")
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(8)
    }
}
