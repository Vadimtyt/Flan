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
    let regionInMeters = 500.0
    var placeCoordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceAndTimeLabel: UILabel!
    @IBOutlet weak var startRouteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceAndTimeLabel.isHidden = true
        
        mapView.delegate = self
        setupPlacemarkFor(bakery)
        checkLocationServesieces()
    }
    
    func setupPlacemarkFor(_ bakery: Bakery) {
        let address = bakery.address
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("Москва, " + address) { [weak self, weak bakery] (placemarks, error) in
            
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
            self?.placeCoordinate = placemarkLocation.coordinate
            
            self?.mapView.showAnnotations([annotation], animated: true)
            self?.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocationServesieces() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorisation()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.turnOnLocationAlert(message: "Пожалуйста, перейдите в настройки и включите службы геолокации.")
            }
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
        
    func getDirection() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Ошибка", message: "Ваше местоположение не найдено")
            return
        }
        
        locationManager.startUpdatingLocation()
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Ошибка", message: "Ваше местоположение не найдено")
            return
        }
        
        
        let direction = MKDirections(request: request)
        
        direction.calculate { [weak self] (response, error) in
            if let error = error {
                print(error)
                self?.showAlert(title: "Ошибка", message: "Пешие маршруты недоступны")
                return
            }
            
            guard let response = response else {
                self?.showAlert(title: "Ошибка", message: "Не удалось получить маршрут")
                return
            }
            
            for route in response.routes {
                self?.mapView.addOverlay(route.polyline)
                self?.mapView.setVisibleMapRect(route.polyline.boundingMapRect , animated: true)
                
                let distance = String(Int(route.distance))
                let timeInterval = Int(route.expectedTravelTime/60)
                
                self?.distanceAndTimeLabel.text! = " \(distance)м.\n"
                self?.distanceAndTimeLabel.text! += " \(timeInterval)мин."
                
                self?.distanceAndTimeLabel.isHidden = false
                
                self?.startRouteButton.isHidden = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                    self?.showUserLocation()
                    self?.distanceAndTimeLabel.isHidden = true
                }
            }
        }
    }
    
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = self.placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    func showUserLocation() {
        checkLocationAuthorisation()
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Ошибка", message: "Ваше местоположение не найдено")
            print("kek")
            return
        }
        let region = MKCoordinateRegion(center: location,
                                        latitudinalMeters: regionInMeters,
                                        longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func closeVC(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.medium)
        dismiss(animated: true)
    }
    
    @IBAction func myPositionButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        showUserLocation()
    }
    
    @IBAction func startRouteButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        getDirection()
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
        checkLocationAuthorisation()
    }
}

extension MapVC {
    func turnOnLocationAlert(message: String) {
        let title = "Службы геолокации недоступны"
        
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
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OpenSettingsAction action
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}

