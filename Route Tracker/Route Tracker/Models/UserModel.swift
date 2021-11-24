//
//  UserModel.swift
//  Route Tracker
//
//  Created by Leo Malikov on 24.11.2021.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login = ""
    @objc dynamic var password = ""
    
    override class func primaryKey() -> String? {
        return "login"
    }
    
    convenience init(_ login: String, _ password: String) {
        self.init()
        self.login = login
        self.password = password
    }
}
