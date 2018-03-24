//
//  SidemenuVC.swift
//  instagram-cloned
//
//  Created by Rishabh Anand on 28/02/18.
//  Copyright © 2018 Rishabh Anand. All rights reserved.
//

import UIKit

class SidemenuVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        if(indexPath.row == 0){
            // my uploads
            NotificationCenter.default.post(name: NSNotification.Name("ToMyUploads"), object: nil)
        }else if(indexPath.row == 1) {
            // profile
            NotificationCenter.default.post(name: NSNotification.Name("ShowProfile"), object: nil)
        } else if(indexPath.row == 2) {
            // settings
            NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
        } else if(indexPath.row == 3){
            // add friends
            NotificationCenter.default.post(name: NSNotification.Name("ToAddFriends"), object: nil)
        }
    }

}
