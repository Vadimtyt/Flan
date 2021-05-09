//
//  MapVC.swift
//  Flan
//
//  Created by Вадим on 09.05.2021.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    var bakery: Bakery!
    let annotationID = "annotationID"
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupPlacemarkFor(bakery)

    }
    
    func setupPlacemarkFor(_ bakery: Bakery) {
        let address = bakery.address
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("Славянск-на-Кубани, " + address) { [weak self, weak bakery] (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = bakery?.name
            annotation.subtitle = bakery?.address
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self?.mapView.showAnnotations([annotation], animated: true)
            self?.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    @IBAction func closeVC(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            annotationView?.canShowCallout = true
        }
        
        return annotationView
    }
}
