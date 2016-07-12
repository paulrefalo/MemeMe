//
//  File.swift
//  ImagePicker
//
//  Created by Paul ReFalo on 7/1/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var segueSource : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(segueSource)
        if segueSource == "fromAlbum" {
            pickAnImageFromAlbum()
        } else if segueSource == "fromCamera" {
            pickAnImageFromCamera()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    func pickAnImageFromAlbum() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func pickAnImageFromCamera () {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
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
        imagePickerView.image = newImage
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction private func userDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}