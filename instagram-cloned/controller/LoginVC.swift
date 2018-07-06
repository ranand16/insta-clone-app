//
//  ViewController.swift
//  instagram-cloned
//
//  Created by Rishabh Anand on 27/02/18.
//  Copyright © 2018 Rishabh Anand. All rights reserved.
//

import UIKit
import Parse

class LoginVC: UIViewController {

    var signUpMode: Bool = true
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    // a common function for displaying alert
    func alertDisplay(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            performSegue(withIdentifier: "showUserTable", sender: self)
        }
        navigationController?.navigationBar.isHidden = true
    }

    @IBAction func signUpOrInPressed(_ sender: Any) {
        if usernameTF.text == "" || passwordTF.text == "" {
            
            alertDisplay(title: "Error", message: "It seems you have left some fields blank")
            
        } else {
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = .gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            if signUpMode {
                // Sign Up
                let user = PFUser()
                user.username = usernameTF.text
                user.password = passwordTF.text
                
                user.signUpInBackground { (user, err) in
                    if err != nil {
                        print("We had an error while signup", err.debugDescription)
                        self.alertDisplay(title: "Error", message: err.debugDescription)
                        activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    } else {
                        print("Succesfully cretead the user")
                        activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                }
            } else {
        
                PFUser.logInWithUsername(inBackground: usernameTF.text!, password: passwordTF.text!, block: { (user, err) in
                    if err != nil {
                        self.alertDisplay(title: "Error", message: err.debugDescription)
                        activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.usernameTF.text = ""
                        self.passwordTF.text = ""
                    } else {
                        print("Succesfully logged in")
                        activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                })
            }
        }
    }
    
    @IBAction func signInOrUpTogglePressed(_ sender: Any) {
        
        // to toggle the "Sign In" & "Sign Up" button
        if signInBtn.currentTitle! == "Sign In" {
            signUpMode = false
            signInBtn.setTitle("Sign Up", for: [])
            signUpBtn.setTitle("Sign In", for: [])
        } else {
            signUpMode = true
            signInBtn.setTitle("Sign In", for: [])
            signUpBtn.setTitle("Sign Up", for: [])
        }
    }
}

