//
//  MapViewController.swift
//  Route Tracker
//
//  Created by Lev on 11/7/21.
//
import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {

    let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    
    var locationManager: CLLocationManager?
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLoactionManager()
        locationManager?.delegate = self
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.camera = camera
    }

    func configureLoactionManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
    }
 
    @IBAction func updateLocation(_ sender: Any) {
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager?.requestLocation()
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = (locations.first?.coordinate)!
        mapView.animate(toLocation: coordinate)
        
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}
