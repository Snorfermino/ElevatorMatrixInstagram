//
//  InstagramViewController.swift
//  UmbalaAnswer
//
//  Created by Tien Dat on 9/3/16.
//  Copyright © 2016 Tien Dat. All rights reserved.
//

import UIKit
import InstagramKit
@objc protocol InstagramViewControllerDelegate{
    optional func instagramViewController(instaVC : InstagramViewController)
}
class InstagramViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var tableView:UITableView!
    var delegate:InstagramViewControllerDelegate?
    var instagramEngine:InstagramEngine?
    var user:InstagramUser?
    var result:[AnyObject]?
    var accessToken:String!
    override func viewWillAppear(animated: Bool) {
        tableView.alpha = 0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        instagramEngine = InstagramEngine.sharedEngine()
        
        let authUrl:NSURL = InstagramEngine.sharedEngine().authorizationURL()
        let scopeauthURL:NSURL = InstagramEngine.sharedEngine().authorizationURLForScope(InstagramKitLoginScope.Relationships)
        print(authUrl)
        webView.scrollView.bounces = false
        webView.delegate = self
        self.webView.loadRequest(NSURLRequest(URL: scopeauthURL))
        print("open login")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InstagramViewController.reloadData),name:"reloadData", object: nil)

    }
    
    func reloadData(notification:NSNotification){
        print("reload")
        self.view.setNeedsLayout()
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func CloseInstagram(sender: UIBarButtonItem) {
      UIView.animateWithDuration(0.5) { 
        self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
  
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InstagramViewController: UIWebViewDelegate{
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var user:InstagramUser?
        
        do {
            try InstagramEngine.sharedEngine().receivedValidAccessTokenFromURL(request.URL!)
            accessToken = instagramEngine?.accessToken
            print("after received token: \(accessToken)")

            
            instagramEngine?.getSelfUserDetailsWithSuccess({ (InstagramUser) in
                 user = InstagramUser
                print(user!.fullName)
                print(user!.followsCount)
                print(user!.followedByCount)
                print(user!.username)
                //print(InstagramKitLoginScope.Relationships)
                
                self.instagramEngine?.getUsersFollowedByUser(user!.Id, withSuccess: { (result: [InstagramKit.InstagramUser], page: InstagramPaginationInfo) in
                    print("here Following")
                    print(result.count)
                    for r in result {
                        print (r.fullName)
                    }
                    self.result = result
                    self.tableView.reloadData()
                    }, failure: { (error, index) in
                        print(error.localizedDescription)
                })
                
                self.instagramEngine?.getRelationshipStatusOfUser(user!.Id, withSuccess: { (result :[NSObject : AnyObject]) in
                    print("relationship: ")
                    print(result)
                    for r in result {
                        print (r)
                    }
                    }, failure: { (error, i) in
                        print(error.localizedDescription)
                })
                
                
                self.instagramEngine?.getFollowRequestsWithSuccess({ (userRequest, pagination) in
                    
                    print(" request \(userRequest)")
                    }, failure: { (error, index) in
                        print(error.localizedDescription)
                })
                
                

                
                self.instagramEngine?.getFollowersOfUser(user!.Id, withSuccess: { (result: [InstagramKit.InstagramUser], InstagramPaginationInfo) in
                    print("here Follower")
                    print(result.count)
                    for r in result {
                        print (r.fullName)
                    }
                    webView.alpha = 0
                    self.tableView.alpha = 1
                    }, failure: { (error, index) in
                        print(error.localizedDescription)
                })
                
                //user?.valueForKeyPath("")
                }, failure: { (error, index) in
                    print(error.localizedDescription)
            })
            
            instagramEngine?.getSelfFeedWithSuccess({ (result, nil) in
                print("after received 2")
                self.result = result
                print("get something")
                }, failure: { (error: NSError,index: Int) in
                    print(error.localizedDescription)
            })
            
        } catch  {
           print(error)
        }
        
        
        return true
    }
    
   
}

extension InstagramViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result?.count ??  0
    }
   
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingCell
        cell.usernameLabel.text = result![indexPath.row].fullName
        cell.ImgURL = String(result![indexPath.row].profilePictureURL!)
        cell.userAvatarImageView.setImageWithURL(result![indexPath.row].profilePictureURL!!)
        cell.userId = result![indexPath.row].Id
        cell.delegate = self
        return cell
    }
    
}

extension InstagramViewController: FollowingCellDelegate{
    
    func updateTable() {
        tableView.reloadData()
        print("delegate triggered")
    }
}