//
//  MapViewController.swift
//  Route Tracker
//
//  Created by Lev on 11/7/21.
//
import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift

class MapViewController: UIViewController {

    let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    
    var locationManager: CLLocationManager?
    
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    
    let blurViewTag: Int = 330
    
    @IBOutlet weak var startTrackingButton: UIButton!
    @IBOutlet weak var stopTrackingButton: UIButton!
    @IBOutlet weak var showLastTrackButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLoactionManager()
        configureNotificationCenter()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deconfigureNotificationCenter()
    }
    
    // Notification center
    
    func configureNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeInactive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    func deconfigureNotificationCenter() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc func applicationDidBecomeActive() {
        removeBlur()
    }
    
    @objc func applicationDidBecomeInactive() {
        addBlur()
    }
    
    func addBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.tag = blurViewTag
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    
    func removeBlur() {
        if let blurView = view.viewWithTag(blurViewTag) {
            blurView.removeFromSuperview()
        }
    }
    
    // Map
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.camera = camera
    }

    func configureLoactionManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.requestWhenInUseAuthorization()
    }
 
    @IBAction func updateLocation(_ sender: Any) {
        mapView.clear()
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func stopUpdatingLocation(_ sender: Any) {
        locationManager?.stopUpdatingLocation()
        guard let path = routePath else { return }
        var newPathCoordinates = [Coordinate]()
        for i in 0..<path.count() {
            guard let coordinate = routePath?.coordinate(at: i) else { return }
            let newPathCoordinate = Coordinate(coordinate.latitude, coordinate.longitude)
            newPathCoordinates.append(newPathCoordinate)
        }
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            realm.add(newPathCoordinates)
        }
        routePath = nil
        route?.map = nil
    }
    
    @IBAction func showLastTrack(_ sender: Any) {
        guard routePath == nil else {
            let alert = UIAlertController(title: "Error", message: "You should stop tracking to see your previous route", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Stop", style: .destructive, handler: { [weak self] _ in
                self?.stopUpdatingLocation(alert)
                self?.showTrack()
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        showTrack()
    }
    
    func showTrack() {
        let path = GMSMutablePath()
        
        let realm = try! Realm()
        let coordinates = Array(realm.objects(Coordinate.self))
        coordinates.forEach { coordinate in
            let cllocationcoordinate2d = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longtitude)
            path.add(cllocationcoordinate2d)
        }
        
        let polyline = GMSPolyline(path: path)
        polyline.map = mapView
        
        let bounds = GMSCoordinateBounds(path: path)
        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())
        mapView.animate(to: camera!)
    }
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager?.requestLocation()
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        routePath?.add(location.coordinate)
        route?.path = routePath
        
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.animate(to: position)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}
