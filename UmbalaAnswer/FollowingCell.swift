//
//  FollowingCell.swift
//  UmbalaAnswer
//
//  Created by Tien Dat on 9/4/16.
//  Copyright © 2016 Tien Dat. All rights reserved.
//

import UIKit
import AFNetworking
import InstagramKit
@objc protocol FollowingCellDelegate{
    func updateTable()
}
class FollowingCell: UITableViewCell {

    var instagramEngine:InstagramEngine?
    @IBOutlet var usernameLabel:UILabel!
    @IBOutlet var userAvatarImageView:UIImageView!
    @IBOutlet var followingButton:UIButton!
    var delegate:FollowingCellDelegate?
    var userId:String!
    var ImgURL:String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        followingButton.backgroundColor = hexStringToUIColor("#70c050")
        instagramEngine = InstagramEngine.sharedEngine()
        userAvatarImageView.setImageWithURL(NSURL(string: ImgURL)!)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    @IBAction func followingPressed(sender: AnyObject) {
        
        
        self.instagramEngine?.unfollowUser(userId, withSuccess: { (objects: [NSObject : AnyObject]) in
            print(objects)
            NSNotificationCenter.defaultCenter().postNotificationName("reloadData",object: self)
            }, failure: { (error, i) in
               print("\(error.localizedDescription) with index \(i)")
        })
                
    }
    

}
