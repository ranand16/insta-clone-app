//
//  MyUploadDetailVC.swift
//  instagram-cloned
//
//  Created by Rishabh Anand on 20/03/18.
//  Copyright © 2018 Rishabh Anand. All rights reserved.
//

import UIKit
import Parse

class MyUploadDetailVC: UIViewController {
    
    @IBOutlet weak var myPostImage: UIImageView!
    @IBOutlet weak var myUsername: UILabel!
    @IBOutlet weak var myComent: UILabel!
    @IBOutlet weak var myProfilePic: UIImageView!
    
    var rowDetails : PFObject? = nil
    var toBeReceived = [Any]()
//    var rowDetails = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(rowDetails as Any)
        myPostImage.image = nil
        myComent.text = ""
        
        myComent.text = rowDetails?["message"] as? String
        myProfilePic.image = toBeReceived[0] as? UIImage
        myUsername.text = toBeReceived[1] as? String
        (rowDetails!["imageFile"] as! PFFile).getDataInBackground { (imageData, err) in
            if let imageData = imageData{
                if let imageToDisplay = UIImage(data: imageData){
                    self.myPostImage.image = imageToDisplay
                }
            }
        }
    }
}
