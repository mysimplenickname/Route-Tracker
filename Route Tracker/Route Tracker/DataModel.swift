//
//  DataModel.swift.swift
//  Route Tracker
//
//  Created by Leo Malikov on 22.11.2021.
//

import Foundation
import RealmSwift

class Coordinate: Object {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longtitude = 0.0
    
    convenience init(_ latitude: Double, _ longitude: Double) {
        self.init()
        self.latitude = latitude
        self.longtitude = longitude
    }
}
