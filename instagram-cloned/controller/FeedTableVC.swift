//
//  FeedTableVC.swift
//  instagram-cloned
//
//  Created by Rishabh Anand on 27/02/18.
//  Copyright © 2018 Rishabh Anand. All rights reserved.
//

import UIKit
import Parse
import Floaty

class FeedTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    // finding userId of current user
    let userId : String = (PFUser.current()?.objectId)!
    var users = [String: String]()
    var comments = [String]()
    var usernames = [String]()
    var profileIcons = [String : PFFile]()
    var imageFiles = [PFFile]()
    var postIds = [String]()

    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var postFloaty: Floaty!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showProfile), name: NSNotification.Name("ShowProfile"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSettings), name: NSNotification.Name("ShowSettings"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toAddFriends), name: NSNotification.Name("ToAddFriends"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toMyUploads), name: NSNotification.Name("ToMyUploads"), object: nil)
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        // for the floaty plus button in the bottom righ corner
        postFloaty.addItem(title: "New Post") { (item) in
            self.performSegue(withIdentifier: "newPostSegue", sender: self)
        }
        
        // find usernames for their objectIds
        let userQuery = PFUser.query()
        userQuery?.whereKey("username", notEqualTo: PFUser.current()?.username! as Any)
        userQuery?.findObjectsInBackground(block: { (objects, err) in
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        self.users[user.objectId!] = user.username
                        if user.value(forKey: "profilePic") != nil {
                            self.profileIcons[user.username!] = user.value(forKey: "profilePic") as? PFFile
                        } else {
                            self.profileIcons[user.username!] = nil
                        }
                    }
                }
            }
            
            // finding the following list in class "Following" and their posts in class "Post"
            let followingQuery = PFQuery(className: "Following")
            followingQuery.whereKey("follower", equalTo: self.userId)
            followingQuery.findObjectsInBackground { (objects, err) in
                if let followings = objects {
                    for following in followings{
                        if let followedUser = following["following"] {
                            
                            let postQuery = PFQuery(className: "Post")
                            postQuery.whereKey("userid", equalTo: followedUser)
                            postQuery.findObjectsInBackground(block: { (objects, err) in
                                if let posts = objects {
                                    for post in posts {
                                        self.postIds.append(post.objectId!) // will be used while downloading the full size image form the server on click
                                        self.comments.append(post["message"] as! String)
                                        self.usernames.append(self.users[post["userid"] as! String]!)
                                        self.imageFiles.append(post["imageFile"] as! PFFile)
                                        self.feedTableView.reloadData()
                                    }
                                }
                            })
                        }
                    }
                }
            }
        })
    }

    // for removing the fullscreened image
    @objc func removeImage() {
        
        self.navigationController?.isNavigationBarHidden = false
        let imageView = (self.view.viewWithTag(100)! as! UIImageView)
        imageView.removeFromSuperview()
        imageView.image = nil;
    }
    
    // for fullscreening the clicked image
    func addImageViewWithImage(image: UIImage) {
        
        // creating the image
        let imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        imageView.image = image
        imageView.isUserInteractionEnabled = true
        imageView.tag = 100
        self.navigationController?.isNavigationBarHidden = true
        self.view.addSubview(imageView)
        
        // tap again to remove the fullscreen image
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.removeImage))
        dismissTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(dismissTap)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageFiles.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FeedTableViewCell
        
        // make the background clear for the selected cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        
        cell.contentView.backgroundColor = UIColor.clear
//        print(postIds[indexPath.row])
        self.addImageViewWithImage(image: cell.postImage.image!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedTableViewCell
//        setting all the table cell value to nil to load new data without any scroll repeatition errors
        cell.commentTF.text = ""
        cell.usernameTF.text = ""
        cell.postImage.image = nil
        cell.profileIcon.image = #imageLiteral(resourceName: "user.png")
        cell.postImage.isUserInteractionEnabled = true
        
//        setting the new value for the current cell cycle
        imageFiles[indexPath.row].getDataInBackground { (imageData, err) in
            if let imageData = imageData {
                if let imageToDisplay = UIImage(data: imageData){
                    cell.postImage.image = imageToDisplay
                }
            }
        }
        profileIcons[usernames[indexPath.row]]?.getDataInBackground(block: { (profilePicData, err) in
            if profilePicData != nil {
                let profilePicData = profilePicData
                if let profileImageToDisplay = UIImage(data: profilePicData!){
                    cell.profileIcon.image = profileImageToDisplay
                }
            } else {
                cell.profileIcon.image = nil
            }
        })
        cell.commentTF.text = comments[indexPath.row]
        cell.usernameTF.text = usernames[indexPath.row]
        
        return cell
    }
    
    @objc func showProfile(){
        performSegue(withIdentifier: "profileSegue", sender: nil)
    }
    
    @objc func showSettings(){
        performSegue(withIdentifier: "settingsSegue", sender: nil)
    }
    
    @objc func toAddFriends(){
        performSegue(withIdentifier: "toAddFriendScreen", sender: nil)
    }
    
    @objc func toMyUploads(){
        performSegue(withIdentifier: "toMyUploads", sender: nil)
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        PFUser.logOut()
        NotificationCenter.default.post(name: NSNotification.Name("ToSignInScreen"), object: nil)
    }
    
    @IBAction func hamburgerPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
}





