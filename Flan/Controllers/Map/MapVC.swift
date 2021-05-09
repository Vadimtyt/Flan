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
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupPlacemarkFor(bakery)
        
        // Do any additional setup after loading the view.
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
