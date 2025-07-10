//
//  PLaceSEarch.swift
//  GoogleMapSwiftUI
//
//  Created by Arjunan on 09/07/25.
//

import SwiftUI
import GooglePlaces

struct PlacesSearchView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var onPlaceSelected: (GMSPlace) -> Void

    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator
        return autocompleteController
    }

    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        let parent: PlacesSearchView

        init(parent: PlacesSearchView) {
            self.parent = parent
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            parent.onPlaceSelected(place)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            print("Autocomplete failed: \(error.localizedDescription)")
            parent.presentationMode.wrappedValue.dismiss()
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
