//
//  TimelineTableViewController.swift
//  SwifferApp
//
//  Created by Training on 29/06/14.
//  Copyright (c) 2014 Training. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController {

    var timelineData:NSMutableArray = NSMutableArray()
    
    init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
        
        if (!PFUser.currentUser()){
            var loginAlert:UIAlertController = UIAlertController(title: "Sign Up / Login", message: "Please sign up or login", preferredStyle: UIAlertControllerStyle.Alert)
            
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your username"
                })
            
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your password"
                textfield.secureTextEntry = true
                })
            
            loginAlert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields:NSArray = loginAlert.textFields as NSArray
                let usernameTextfield:UITextField = textFields.objectAtIndex(0) as UITextField
                let passwordTextfield:UITextField = textFields.objectAtIndex(1) as UITextField
                
                PFUser.logInWithUsernameInBackground(usernameTextfield.text, password: passwordTextfield.text){
                    (user:PFUser!, error:NSError!)->Void in
                    if (user){
                        println("Login successfull")
                    }else{
                        println("Login failed")
                    }
                    
                    
                }
                
                
                
                
                }))
            
            loginAlert.addAction(UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields:NSArray = loginAlert.textFields as NSArray
                let usernameTextfield:UITextField = textFields.objectAtIndex(0) as UITextField
                let passwordTextfield:UITextField = textFields.objectAtIndex(1) as UITextField
                
                var sweeter:PFUser = PFUser()
                sweeter.username = usernameTextfield.text
                sweeter.password = passwordTextfield.text
                
                sweeter.signUpInBackgroundWithBlock{
                    (success:Bool!, error:NSError!)->Void in
                    if !error{
                        println("Sign Up successfull")
                    }else{
                        let errorString = error.userInfo["error"] as String
                        println(errorString)
                    }
                    
                    
                }
                
                
                
                }))
            
            self.presentViewController(loginAlert, animated: true, completion: nil)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    
    @IBAction func loadData(){
        timelineData.removeAllObjects()
        
        var findTimelineData:PFQuery = PFQuery(className: "Sweets")
        
        findTimelineData.findObjectsInBackgroundWithBlock{
            (objects:AnyObject[]!, error:NSError!)->Void in
            
            if !error{
                for object:PFObject! in objects{
                    self.timelineData.addObject(object)
                }
                
                let array:NSArray = self.timelineData.reverseObjectEnumerator().allObjects
                self.timelineData = array as NSMutableArray
                
                self.tableView.reloadData()
                
            }
            
        }
    }

    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TimelineTableViewController{ // TableView Datasource and Delegate
    // #pragma mark - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return timelineData.count
    }
    
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell:SweetTableViewCell = tableView!.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath!) as SweetTableViewCell
        
        let sweet:PFObject = self.timelineData.objectAtIndex(indexPath!.row) as PFObject
        
        cell.sweetTextView.alpha = 0
        cell.timestampLabel.alpha = 0
        cell.usernameLabel.alpha = 0
        
        cell.sweetTextView.text = sweet.objectForKey("content") as String
        
        
        var dataFormatter:NSDateFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.timestampLabel.text = dataFormatter.stringFromDate(sweet.createdAt)
        
        var findSweeter:PFQuery = PFUser.query()
        findSweeter.whereKey("objectId", equalTo: sweet.objectForKey("sweeter").objectId)
        
        findSweeter.findObjectsInBackgroundWithBlock{
            (objects:AnyObject[]!, error:NSError!)->Void in
            if !error{
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                cell.usernameLabel.text = user.username
                
                UIView.animateWithDuration(0.5, animations: {
                    cell.sweetTextView.alpha = 1
                    cell.timestampLabel.alpha = 1
                    cell.usernameLabel.alpha = 1
                    })
            }
        }
        
        
        return cell
    }

}
