//
//  ViewController.swift
//  ImagePicker
//
//  Created by Paul ReFalo on 6/30/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var toolbar: UIToolbar!
//    @IBOutlet weak var navbar: UINavigationBar!

    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),     //TODO: Fill in appropriate UIColor
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -5.0,                   //TODO: Fill in appropriate Float
        ]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        if (imagePickerView.image != nil) {
            topTextField.alpha = 1
            bottomTextField.alpha = 1
            shareButton.enabled = true
        } else {
            topTextField.alpha = 0
            bottomTextField.alpha = 0
            shareButton.enabled = false
        }
        
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self

    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField.tag == -1 {
            topTextField.text = ""
            topTextField.tag = 1
        }
        
        if textField.tag == -2 {
            bottomTextField.text = ""
            bottomTextField.tag = 2
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC : ImageViewController = segue.destinationViewController as! ImageViewController

        if segue.identifier == "getImageFromAlbum" {
            destinationVC.segueSource = "fromAlbum"
        } else if segue.identifier == "getImageFromCamera" {
            destinationVC.segueSource = "fromCamera"
        }
    }
    
 
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        
        
        // hand the object in
        let sharedImage = generateMemedImage()
        
        // Activity Controller View
        let nextController = UIActivityViewController(activityItems: [sharedImage], applicationActivities: nil)
        
        //Handler for completion
        nextController.completionWithItemsHandler = { activity, success, items, error in
            
            if (success == true) {
                //Generate a memed image
                self.save(sharedImage)
                
                //Dismiss
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
        
        // Present the view
        self.presentViewController(nextController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        // do something interesting here!
        //        print(newImage.size)
        print(newImage)
        
        
        let newSize:CGSize = CGSize(width: 250,height: 250)
        let rect = CGRectMake(0,0, newSize.width, newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        
        // image is a variable of type UIImage
        newImage.drawInRect(rect)
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        
        imagePickerView.image = newImage  // resizedImage
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save(saveImage : UIImage) {
        //Create the meme
        var meme = Meme(
            topText : topTextField.text!,
            bottomText : bottomTextField.text!,
            image : imagePickerView.image!,
            memedImage : generateMemedImage() )
        
        //Add meme to array in app delegate
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
        let savedMemes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        navigationController?.navigationBarHidden = true
        
        toolbar.hidden = true
//        navbar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // TODO:  Show toolbar and navbar 
        toolbar.hidden = false
//        navbar.hidden = false
        
        return memedImage
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("Keyboard will show")
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("Keyboard will hide")
        view.frame.origin.y = 0

//        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        print("get Keyboard Height")
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
        print("subscribe to keyboard notifications")
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        print("UNsubscribe to keyboard notifications")

    }
    

    
}

struct Meme {
    var topText : String
    var bottomText : String
    var image : UIImage
    var memedImage : UIImage
}



