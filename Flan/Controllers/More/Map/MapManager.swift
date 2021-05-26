//
//  MapManager.swift
//  Flan
//
//  Created by Вадим on 16.05.2021.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    var placeCoordinate: CLLocationCoordinate2D?
    let regionInMeters = 500.0
    
    func setupPlacemarkFor(_ bakery: Bakery, on mapView: MKMapView) {
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
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocationServices(mapView: MKMapView, closure: ()->()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorisation(mapView: mapView)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.turnOnLocationAlert(message: "Пожалуйста, перейдите в настройки и включите службы геолокации.")
            }
        }
    }
    
    func checkLocationAuthorisation(mapView: MKMapView) {
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
    
    func showUserLocation(mapView: MKMapView) {
        checkLocationAuthorisation(mapView: mapView)
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
    
    func getDirection(mapView: MKMapView, distanceAndTimeLabel: UILabel) {
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
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect , animated: true)
                
                let distance = String(Int(route.distance))
                let timeInterval = Int(route.expectedTravelTime/60)
                
                distanceAndTimeLabel.text! = " \(distance)м.\n"
                distanceAndTimeLabel.text! += " \(timeInterval)мин."
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
}

extension MapManager {
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
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OK action
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
