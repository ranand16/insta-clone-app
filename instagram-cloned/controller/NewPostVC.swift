//
//  NewPostVC.swift
//  instagram-cloned
//
//  Created by Rishabh Anand on 28/02/18.
//  Copyright © 2018 Rishabh Anand. All rights reserved.
//

import UIKit
import Parse
import Zip

class NewPostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var newPostImageView: UIImageView!
    @IBOutlet weak var commentTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // a common function for displaying alert
    func alertDisplay(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectImageBtnPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newPostImageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
     
    @IBAction func postBtnPressed(_ sender: Any) {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        if let image = newPostImageView.image {
            print("img : \(image)")
        
            let post = PFObject(className: "Post")
            post["message"] = commentTF.text
            post["userid"] = PFUser.current()?.objectId
            if let imageData = UIImagePNGRepresentation(image){

                let imageFile = PFFile(name: "Image.png", data: imageData)
                post["imageFile"] = imageFile
                post.saveInBackground(block: { (success, err) in
                    print("Success : \(success)")
                    print("error : \(err)")
                    if success {
                        self.alertDisplay(title: "Image Posted!", message: "Successfully posted the image")
                        self.commentTF.text = ""
                        self.newPostImageView.image = nil
                        activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    } else {
                        self.alertDisplay(title: "Error!!", message: "could not post the image")
                        activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                })
            }
        }
    }
}
