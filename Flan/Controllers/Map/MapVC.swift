//
//  MapVC.swift
//  Flan
//
//  Created by Вадим on 09.05.2021.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    var bakery: Bakery!
    let annotationID = "annotationID"
    let locationManager = CLLocationManager()
    let regionInMeters = 5000.0
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupPlacemarkFor(bakery)
        checkLocationServesieces()
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
    
    func checkLocationServesieces() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorisation()
        } else {
            turnOnLocationAlert(message: "Пожалуйста, перейдите в настройки и включите службы геолокации.")
        }
    }
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorisation() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            turnOnLocationAlert(message: "Пожалуйста, перейдите в настройки и разрешите приложению определять ваше местоположение.")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            turnOnLocationAlert(message: "Пожалуйста, перейдите в настройки и разрешите приложению определять ваше местоположение.")
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }

    func turnOnLocationAlert(message: String) {
        let title = "Службы геолокации недоступны"
        let message = "Пожалуйста, перейдите в настройки и разрешите приложению определять ваше местоположение."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OpenSettingsAction action
        let openSettingsAction = UIAlertAction(title: "Настройки", style: .default) {  _ in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(openSettingsAction)
        
        
        present(alert, animated: true)
    }
    
    @IBAction func closeVC(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func myPositionButtonPressed(_ sender: UIButton) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
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
}

extension MapVC: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorisation()
    }
}
