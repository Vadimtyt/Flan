//
//  MapVC.swift
//  Flan
//
//  Created by Вадим on 09.05.2021.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    
    // MARK: - Props
    
    let mapManager = MapManager()
    
    var bakery: Bakery!
    let annotationID = "annotationID"
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceAndTimeLabel: UILabel!
    @IBOutlet weak var startRouteButton: UIButton!
    
    @IBOutlet weak var distanceAndTimeView: UIView!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceAndTimeView.isHidden = true
        
        mapView.delegate = self
        setupMapView()
    }
    
    // MARK: - funcs
    
    private func setupMapView() {
        mapManager.checkLocationServices(mapView: mapView) {
            mapManager.locationManager.delegate = self
        }
        
        mapManager.setupPlacemarkFor(bakery, on: mapView)
    }
    
    // MARK: - @IBActions
    
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
        distanceAndTimeView.layer.cornerRadius = 16
        distanceAndTimeView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.distanceAndTimeView.isHidden = true
            self?.mapManager.showUserLocation(mapView: (self?.mapView)!)
        }
    }
    
}

// MARK: - MKMap view delegate

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

// MARK: - CLLocation manager delegate

extension MapVC: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorisation(mapView: mapView)
    }
}



