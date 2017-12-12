    //
//  ViewController.swift
//  MemeMeV1
//
//  Created by Ansuke on 12/5/17.
//  Copyright © 2017 AM. All rights reserved.
//

// Disable text fields from showing up or being interacted with
// Show place holder text and delete it when user first taps on text field
    
import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextInputTraits {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraBarButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        cameraBarButtonOutlet.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // Text Attributes Setup
        let memeTextAttributes:[String:Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -5.0
        ]
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        // UITextField Attributes
        topTextField.textAlignment = .center
        topTextField.borderStyle = .none
        topTextField.autocapitalizationType = .allCharacters
        topTextField.backgroundColor = UIColor.clear
        topTextField.isEnabled = false
        
        bottomTextField.textAlignment = .center
        bottomTextField.borderStyle = .none
        bottomTextField.autocapitalizationType = .allCharacters
        bottomTextField.backgroundColor = UIColor.clear
        bottomTextField.isEnabled = false
        print("View loaded")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Get image from array
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Error")
            return
        }
        
        // Text Field setup
        topTextField.isEnabled = true
        bottomTextField.isEnabled = true
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        // Get UIView of aspect scaled image and set image
        imageView.image = image
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        let frameView = UIView(frame: frame)
        
        // Update text field constraints
        topTextFieldConstraint.constant = imageView.bounds.height / 2 - frameView.frame.size.height * 0.45
        bottomTextFieldConstraint.constant = imageView.bounds.height / 2 - frameView.frame.size.height * 0.47
        
        // Update AutoLayout
        topTextField.superview?.setNeedsUpdateConstraints()
        topTextField.superview?.setNeedsLayout()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBarButton(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func cancelBarButton(_ sender: UIBarButtonItem) {
        topTextField.isEnabled = false
        bottomTextField.isEnabled = false
        topTextField.text = ""
        bottomTextField.text = ""
        imageView.image = nil
    }
    
    @IBAction func cameraBarButton(_ sender: UIBarButtonItem) {
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .camera
        cameraPicker.delegate = self
        present(cameraPicker, animated: true, completion: nil)
    }
    
    @IBAction func albumBarButton(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

}

