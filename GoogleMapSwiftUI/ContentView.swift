//
//  ContentView.swift
//  GoogleMapSwiftUI
//
//  Created by Arjunan on 09/07/25.
//

import SwiftUI
import GoogleMaps
import GooglePlaces

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State var isShowSearchBar: Bool = false
    @State var selectedPlace: GMSPlace? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.ignoresSafeArea()

                if let location = locationManager.location {
                    GoogleMapView(
                        source: location,
                        destination: selectedPlace?.coordinate
                    )
                    .id("\(location.latitude)-\(location.longitude)-\(selectedPlace?.placeID ?? "none")")
                } else {
                    ProgressView("Locating...")
                }
            }
            .ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowSearchBar = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowSearchBar) {
            PlacesSearchView { place in
                selectedPlace = place
            }
        }    }
}

#Preview {
    ContentView()
}

struct GoogleMapView: UIViewRepresentable {
    var source: CLLocationCoordinate2D
    var destination: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: source.latitude, longitude: source.longitude, zoom: 18)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.clear()

        let sourceMarker = GMSMarker(position: source)
        sourceMarker.title = "You"
        sourceMarker.icon = GMSMarker.markerImage(with: .blue)
        sourceMarker.map = uiView

        guard let destination else {
            uiView.animate(to: GMSCameraPosition.camera(withTarget: source, zoom: 18))
            return
        }

        let destMarker = GMSMarker(position: destination)
        destMarker.title = "Destination"
        destMarker.icon = GMSMarker.markerImage(with: .red)
        destMarker.map = uiView

        let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
        uiView.moveCamera(GMSCameraUpdate.fit(bounds, withPadding: 50))

        Task {
            do {
                let routeCoords = try await fetchRoutePoints(from: source, to: destination)

                let path = GMSMutablePath()
                routeCoords.forEach { path.add($0) }

                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = .systemBlue
                polyline.strokeWidth = 4
                polyline.map = uiView
            } catch {
                print("❌ Failed to fetch route: \(error)")
            }
        }
    }
}

func fetchRoutePoints(
    from origin: CLLocationCoordinate2D,
    to destination: CLLocationCoordinate2D
) async throws -> [CLLocationCoordinate2D] {
    let apiKey = apiKey
    let urlString = """
    https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&key=\(apiKey)
    """

    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }

    let (data, _) = try await URLSession.shared.data(from: url)

    if let jsonStr = String(data: data, encoding: .utf8) {
        print("🔍 Raw Response: \(jsonStr)")
    }

    guard
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
        let status = json["status"] as? String,
        status == "OK"
    else {
        throw NSError(domain: "GoogleDirectionsAPIError", code: 2, userInfo: [
            NSLocalizedDescriptionKey: "Directions API returned an error"
        ])
    }

    guard
        let routes = json["routes"] as? [[String: Any]],
        let route = routes.first,
        let overviewPolyline = route["overview_polyline"] as? [String: Any],
        let polylineString = overviewPolyline["points"] as? String,
        let path = GMSPath(fromEncodedPath: polylineString)
    else {
        throw NSError(domain: "RouteParsingError", code: 1, userInfo: nil)
    }

    var coords: [CLLocationCoordinate2D] = []
    for i in 0..<path.count() {
        coords.append(path.coordinate(at: i))
    }

    return coords
}
