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
import RxSwift
import RxCocoa
import RxRelay

class MapViewController: UIViewController {

    let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var userImage = UIImage(systemName: "person")
    
    let locationManager = LocationManager.instance
    
    var blurManager: BlurManager!
    
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    
    var marker: GMSMarker?
    
    @IBOutlet weak var startTrackingButton: UIButton!
    @IBOutlet weak var stopTrackingButton: UIButton!
    @IBOutlet weak var showLastTrackButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBlur()
        configureMap()
        configureLocationManager()
    }
    
    // MARK: - Blur
    
    func configureBlur() {
        blurManager = BlurManager(for: view)
    }
    
    // MARK: - Map
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.camera = camera
    }

    func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location else { return }
                self?.routePath?.add(location.coordinate)
                self?.route?.path = self?.routePath
            
                self?.marker?.position = location.coordinate
                
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
            }
    }
 
    @IBAction func updateLocation(_ sender: Any) {
        
        mapView.clear()
        
        route?.map = nil
        
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        
        let iconImageView: UIImageView = {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            imageView.contentMode = .scaleAspectFit
            imageView.image = userImage
            return imageView
        }()
        
        marker = GMSMarker()
        marker?.iconView = iconImageView
        marker?.map = mapView
        
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func stopUpdatingLocation(_ sender: Any) {
        
        locationManager.stopUpdatingLocation()
        
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
        
        marker?.map = nil
        marker = nil
        
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
        locationManager.requestLocation()
    }
    
}
