//
//  LoginViewController.swift
//  Route Tracker
//
//  Created by Leo Malikov on 24.11.2021.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logIn(_ sender: Any) {
        guard
            let login = loginTextField.text,
            let password = passwordTextField.text
        else { return }
        
        let realm = try! Realm()
        guard
            let user = realm.object(ofType: User.self, forPrimaryKey: login),
            user.password == password
        else {
            print("Wrong login or password :(")
            return
        }
        
        print("Success! You're logged in!")
        performSegue(withIdentifier: "toMap", sender: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {
        guard
            let login = loginTextField.text,
            let password = passwordTextField.text
        else { return }
        
        let realm = try! Realm()
        guard let user = realm.object(ofType: User.self, forPrimaryKey: login) else {
            try! realm.write {
                realm.add(User(login, password))
            }
            print("Success! You're signed up!")
            return
        }
        try! realm.write {
            realm.delete(user)
            realm.add(User(login, password))
        }
        print("Success! You're changed your password!")
    }

}
