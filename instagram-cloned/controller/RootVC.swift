//
//  RootVCViewController.swift
//  instagram-cloned
//
//  Created by Rishabh Anand on 27/02/18.
//  Copyright © 2018 Rishabh Anand. All rights reserved.
//

import UIKit

class RootVC: UIViewController {

    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSideMenu), name: NSNotification.Name("ToggleSideMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toSignInScreen), name: NSNotification.Name("ToSignInScreen"), object: nil)
    }

    var sideMenuOpen: Bool = false
    
    @objc func toSignInScreen(){
        performSegue(withIdentifier: "toSignIn", sender: nil)
    }
    
    @objc func toggleSideMenu(){
        if sideMenuOpen {
            sideMenuOpen = false
            sideMenuConstraint.constant = -250
        } else {
            sideMenuOpen = true
            sideMenuConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}
