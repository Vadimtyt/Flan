//
//  MapVC.swift
//  Flan
//
//  Created by Вадим on 09.05.2021.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    let mapManager = MapManager()
    
    var bakery: Bakery!
    let annotationID = "annotationID"
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceAndTimeLabel: UILabel!
    @IBOutlet weak var startRouteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceAndTimeLabel.isHidden = true
        
        mapView.delegate = self
        setupMapView()
    }
    
    private func setupMapView() {
        mapManager.checkLocationServesieces(mapView: mapView) {
            mapManager.locationManager.delegate = self
        }
        
        mapManager.setupPlacemarkFor(bakery, on: mapView)
    }
    
    @IBAction func closeVC(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.medium)
        dismiss(animated: true)
    }
    
    @IBAction func myPositionButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func startRouteButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        mapManager.getDirection(mapView: mapView, distanceAndTimeLabel: distanceAndTimeLabel)
        
        startRouteButton.isHidden = true
        distanceAndTimeLabel.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.distanceAndTimeLabel.isHidden = true
            self?.mapManager.showUserLocation(mapView: (self?.mapView)!)
        }
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}

extension MapVC: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorisation(mapView: mapView)
    }
}



