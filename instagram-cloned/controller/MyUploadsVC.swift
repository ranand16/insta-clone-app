//
//  MyUploadsVC.swift
//  instagram-cloned
//
//  Created by Rishabh Anand on 16/03/18.
//  Copyright © 2018 Rishabh Anand. All rights reserved.
//

import UIKit
import Parse

class MyUploadsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    var rowNumb = Int()
    var numberOfPosts = Int()
    
    var myUsername = String()
    var myProfilePic = UIImage()
    var myPosts = [Any]()
    var myPostsImages = [PFFile]()
    
    @IBOutlet weak var myUploadsView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myUploadsView.delegate = self
        myUploadsView.dataSource = self

        fecthMyUploads()
    }
    
    func fecthMyUploads(){
        let myUserIdQuery = PFUser.query()
        myUserIdQuery?.whereKey("username", equalTo: PFUser.current()?.username! as Any)
        myUserIdQuery?.findObjectsInBackground(block: { (object, err) in
            if let object = object{
                for user in object{
                    // fill the profile details on the page
                    
                    if (user["profilePic"]) != nil{
                        (user["profilePic"] as! PFFile).getDataInBackground { (profileImageData, err) in
                            if let profileImageData = profileImageData {
                                if let profileImageToDisplay = UIImage(data: profileImageData){
                                    self.profilePic.image = profileImageToDisplay
                                    self.myProfilePic = profileImageToDisplay
                                }
                            }
                        }
                    }
                    self.myUsername = user["name"] as! String
                    self.fullName.text = user["name"] as? String
                    self.userName.text = user["username"] as? String
                    
                    // fetching all the uploads that belongs to the current user
                    if let userId = user.objectId{
                        let myPostQuery = PFQuery(className: "Post")
                        myPostQuery.whereKey("userid", equalTo: userId)
                        myPostQuery.findObjectsInBackground(block: { (posts, err) in
                            self.numberOfPosts = (posts?.count)!
                            if let posts = posts{
                                for post in posts{
                                    self.myPosts.append(post)
//                                    print(post)
                                    self.myPostsImages.append(post["imageFile"] as! PFFile)
                                    self.myUploadsView.reloadData()
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newProgramVar = myPosts[self.rowNumb]
//        print(self.rowNumb)
        let destinationVC = segue.destination as! MyUploadDetailVC
        destinationVC.rowDetails = nil
        destinationVC.toBeReceived = []
        
        destinationVC.rowDetails = newProgramVar as? PFObject
        destinationVC.toBeReceived.append(myProfilePic)
        destinationVC.toBeReceived.append(myUsername)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 
        rowNumb = indexPath.row
        self.performSegue(withIdentifier: "myPostDetailSegue", sender: self)
    }
    
    // no of cells
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPostsImages.count
    }
    
    // each cell
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myUploadsView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! MyUploadsCVC
        
        myPostsImages[indexPath.row].getDataInBackground { (imageData, err) in
            if let imageData = imageData {
                if let imageToDisplay = UIImage(data: imageData){
                    cell.postImage.image = imageToDisplay
                }
            }
        }
        return cell
    }
}
