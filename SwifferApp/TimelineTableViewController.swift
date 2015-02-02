//
//  TimelineTableViewController.swift
//  SwifferApp
//
//  Created by Training on 29/06/14.
//  Copyright (c) 2014 Training. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var timelineData:NSMutableArray = NSMutableArray()
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
        
        var footerView:UIView = UIView(frame: CGRectMake(0,0, self.view.frame.size.width, 50))
        self.tableView.tableFooterView = footerView
        
        var logoutButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        logoutButton.frame = CGRectMake(20,10,50, 20)
        logoutButton.setTitle("Logout", forState: UIControlState.Normal)
//  added ":" colon to "logout"
        logoutButton.addTarget(self, action: "logout:", forControlEvents: UIControlEvents.TouchUpInside)
        
        footerView.addSubview(logoutButton)

        if PFUser.currentUser() == nil{
            self.showLoginSignUp()

        }

    
    }

    func showLoginSignUp(){
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
            let textFields:NSArray = loginAlert.textFields as [UITextField]
            let usernameTextfield:UITextField = textFields.objectAtIndex(0) as UITextField
            let passwordTextfield:UITextField = textFields.objectAtIndex(1) as UITextField
            
            PFUser.logInWithUsernameInBackground(usernameTextfield.text, password: passwordTextfield.text){
                (user:PFUser!, error:NSError!)->Void in
                if (user != nil){
                    println("Login successfull")
                }else{
                    println("Login failed")
                }
                
                
            }
            
            
            
        }))
        
        loginAlert.addAction(UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = loginAlert.textFields as [UITextField]
            let usernameTextfield:UITextField = textFields.objectAtIndex(0) as UITextField
            let passwordTextfield:UITextField = textFields.objectAtIndex(1) as UITextField
            
            var sweeter:PFUser = PFUser()
            sweeter.username = usernameTextfield.text
            sweeter.password = passwordTextfield.text
            
            sweeter.signUpInBackgroundWithBlock{
                (success:Bool!, error:NSError!)->Void in
                if error == nil {
                    println("Sign Up successfull")
                    var imagePicker:UIImagePickerController = UIImagePickerController()
                    imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                    imagePicker.delegate = self
                    
                    self.presentViewController(imagePicker, animated: true, completion: nil)
                    
                } else {
                    let errorString = error.localizedDescription
                    println(errorString)
                }
                
                
            }
            
            
            
        }))
        
        self.presentViewController(loginAlert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        let pickedImage:UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
        
        // Scale down image
        let scaledImage = self.scaleImageWith(pickedImage, and: CGSizeMake(100, 100))
        
        let imageData = UIImagePNGRepresentation(scaledImage)
        
        let imageFile:PFFile = PFFile(data: imageData)
//          Note:  if we want to name the image...
//        let imageFile:PFFile = PFFile(name: imageName, data: imageData)
        
        PFUser.currentUser().setObject(imageFile, forKey: "profileImage")
        PFUser.currentUser().saveInBackground()
        
//        picker.dismissModalViewControllerAnimated(true)
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    func scaleImageWith(image:UIImage, and newSize:CGSize)->UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0,0, newSize.width, newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    
    @IBAction func loadData(){
        timelineData.removeAllObjects()
        
        var findTimelineData:PFQuery = PFQuery(className: "Sweets")
        
        findTimelineData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            
            if error == nil{
                for object in objects{
                    
                    let sweet:PFObject = object as PFObject
                    self.timelineData.addObject(sweet)
//                    self.timelineData.addObject(object)
                }
                
                let array:NSArray = self.timelineData.reverseObjectEnumerator().allObjects
                self.timelineData = NSMutableArray(array: array)
//                self.timelineData = array as NSMutableArray
                
                self.tableView.reloadData()
                
            }
            
        }
    }

    func logout(sender:UIButton){
        PFUser.logOut()
        self.showLoginSignUp()
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
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:SweetTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as SweetTableViewCell
        
        let sweet:PFObject = self.timelineData.objectAtIndex(indexPath.row) as PFObject
        
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
            (objects:[AnyObject]!, error:NSError!)->Void in
            if error == nil{
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                cell.usernameLabel.text = user.username
                
                // Profile Image
                cell.profileImageView.alpha = 0
                
                let profileImage:PFFile = user["profileImage"] as PFFile
                
                profileImage.getDataInBackgroundWithBlock{
                    (imageData:NSData!, error:NSError!)->Void in
                    
                    if error == nil{
                        let image:UIImage = UIImage(data: imageData)!
                        cell.profileImageView.image = image
                    }
                }
                
                UIView.animateWithDuration(0.5, animations: {
                    cell.sweetTextView.alpha = 1
                    cell.timestampLabel.alpha = 1
                    cell.usernameLabel.alpha = 1
                    cell.profileImageView.alpha = 1
                    })
            }
        }
        
        
        return cell
    }

}
