//
//  ProfileVCViewController.swift
//  instagram-cloned
//
//  Created by Rishabh Anand on 28/02/18.
//  Copyright © 2018 Rishabh Anand. All rights reserved.
//

import UIKit
import Parse

class ProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var fullnameTF: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var genderSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTF.text = PFUser.current()?.username
        fullnameTF.text = PFUser.current()?.value(forKey: "name") as? String
        
        if let imageFile = PFUser.current()?.value(forKey: "profilePic") as? PFFile {
            print(imageFile)
            imageFile.getDataInBackground { (data, err) in
                if let imageData = data {
                    if let imageToDisplay = UIImage(data: imageData){
                        self.profilePic.image = imageToDisplay
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePic.image = image
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func uploadBtnPressed(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        image.sourceType =  UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true, completion: nil)
    }
    
    @IBAction func saveProfilePressed(_ sender: Any) {
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        if let image = profilePic.image {
            PFUser.current()?.setValue(fullnameTF.text , forKey: "name")
            PFUser.current()?.username = usernameTF.text
            
            if let imageData = UIImagePNGRepresentation(image){
                let imageFile = PFFile(name: "profilePic.png", data: imageData)
                PFUser.current()?.setValue(imageFile, forKey: "profilePic")
                PFUser.current()?.saveInBackground(block: { (res, err) in
                    if res && err == nil{
                        activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    } else {
                        print(err.debugDescription ,"not saved")
                    }
                })
            }
            
        }
    }
}
