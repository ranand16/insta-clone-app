//
//  UserTableVC.swift
//  instagram-cloned
//
//  Created by Rishabh Anand on 28/02/18.
//  Copyright © 2018 Rishabh Anand. All rights reserved.
//

import UIKit
import Parse

class UserTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var usernames: [String] = []
    var objectids: [String] = []
    var isFollowing: [String : Bool] = ["" : false]
    @IBOutlet weak var followingTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
    }
    
    func updateTable() {
        
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: PFUser.current()?.username! as Any)
        query?.findObjectsInBackground(block: { (users, err) in
            if err != nil {
                print("Error occured")
            } else {
                if let users = users {
                    self.usernames.removeAll()
                    self.objectids.removeAll()
                    self.isFollowing.removeAll()
                    
                    for object in users {
                        if let user = object as? PFUser {
                            if let username = user.username {
                                if let objectid = user.objectId {
                                    self.objectids.append(objectid)
                                    self.usernames.append(username)
                                    let query = PFQuery(className: "Following")
                                    query.whereKey("follower", equalTo: PFUser.current()?.objectId! as Any)
                                    query.whereKey("following", equalTo: objectid)
                                    query.findObjectsInBackground(block: { (objs, err) in
                                        if let objs = objs {
                                            if objs.count > 0 {
                                                self.isFollowing[objectid] = true
                                            } else {
                                                self.isFollowing[objectid] = false
                                            }
                                            self.followingTable.reloadData()
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = followingTable.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        cell.textLabel?.text = usernames[indexPath.row]
        if let followerBool = isFollowing[objectids[indexPath.row]] {
            if followerBool {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = followingTable.cellForRow(at: indexPath)
        if let followerBool = isFollowing[objectids[indexPath.row]] {
            if followerBool {
                isFollowing[objectids[indexPath.row]] = false
                cell?.accessoryType = UITableViewCellAccessoryType.none
                
                let query = PFQuery(className: "Following")
                query.whereKey("follower", equalTo: PFUser.current()?.objectId! as Any)
                query.whereKey("following", equalTo: objectids[indexPath.row])
                query.findObjectsInBackground(block: { (objs, err) in
                    if let objs = objs {
                        for obj in objs {
                            obj.deleteInBackground()
                        }
                    }
                })
            } else {
                isFollowing[objectids[indexPath.row]] = true
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                let following = PFObject(className: "Following")
                following["follower"] = PFUser.current()?.objectId
                following["following"] = self.objectids[indexPath.row ]
                following.saveInBackground()
            }
        }
    }

    

}
