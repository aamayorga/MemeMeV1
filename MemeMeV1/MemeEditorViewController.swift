//
//  ViewController.swift
//  MemeMeV1
//
//  Created by Ansuke on 12/5/17.
//  Copyright © 2017 AM. All rights reserved.
//
    
import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextInputTraits {

    @IBOutlet weak var actionBarButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var cameraBarButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldConstraint: NSLayoutConstraint!
    
    let memedImage = UIImage()
    let memeTextFieldDelegate = MemeTextFieldDelegate()
    
    var imageAspectRatioFrame = CGRect()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    // Move view so keyboard doesn't hide content
    @objc func keyboardWillShow(_ notification:Notification) {
        if (bottomTextField.isFirstResponder) {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if (bottomTextField.isFirstResponder) {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraBarButtonOutlet.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        actionBarButtonOutlet.isEnabled = false
        
        topTextField.delegate = memeTextFieldDelegate
        bottomTextField.delegate = memeTextFieldDelegate
        
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
        applyTextFieldAttributes(to: topTextField, alignment: .center, borderStyle: .none, autoCapitalization: .allCharacters, backgroundColor: .clear, enabled: false)
        applyTextFieldAttributes(to: bottomTextField, alignment: .center, borderStyle: .none, autoCapitalization: .allCharacters, backgroundColor: .clear, enabled: false)
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
        topTextField.text = "TOP "
        bottomTextField.text = "BOTTOM "
        
        // Get UIView of aspect scaled image and set image
        imageView.image = image
        imageAspectRatioFrame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        let frameView = UIView(frame: imageAspectRatioFrame)
        
        // Update text field constraints
        topTextFieldConstraint.constant = imageView.bounds.height / 2 - frameView.frame.size.height * 0.45
        bottomTextFieldConstraint.constant = imageView.bounds.height / 2 - frameView.frame.size.height * 0.47
        
        // Update AutoLayout
        topTextField.superview?.setNeedsUpdateConstraints()
        topTextField.superview?.setNeedsLayout()
        
        actionBarButtonOutlet.isEnabled = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func applyTextFieldAttributes(to textField: UITextField, alignment: NSTextAlignment, borderStyle: UITextBorderStyle, autoCapitalization: UITextAutocapitalizationType, backgroundColor: UIColor, enabled: Bool) {
        textField.textAlignment = alignment
        textField.borderStyle = borderStyle
        textField.autocapitalizationType = autoCapitalization
        textField.backgroundColor = backgroundColor
        textField.isEnabled = enabled
    }
    
    func createAndPresentImagePickerController(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
    }
    
    // Save just the view where the meme is
    func generateMemedImage() -> UIImage {
        let yOffset = imageView.bounds.maxY - imageAspectRatioFrame.maxY + topToolbar.bounds.height
        
        UIGraphicsBeginImageContext(imageAspectRatioFrame.size)
        view.drawHierarchy(in: self.view.frame.offsetBy(dx: 0, dy: -yOffset), afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    @IBAction func actionBarButton(_ sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
        
        activityVC.completionWithItemsHandler = {(activity, completed, items, error) in
            if completed {
                self.save()
            }
        }
    }
    
    @IBAction func cancelBarButton(_ sender: UIBarButtonItem) {
        actionBarButtonOutlet.isEnabled = false
        topTextField.isEnabled = false
        bottomTextField.isEnabled = false
        topTextField.text = ""
        bottomTextField.text = ""
        imageView.image = nil
    }
    
    @IBAction func cameraBarButton(_ sender: UIBarButtonItem) {
        createAndPresentImagePickerController(delegate: self, sourceType: .camera)
    }
    
    @IBAction func albumBarButton(_ sender: UIBarButtonItem) {
        createAndPresentImagePickerController(delegate: self, sourceType: .photoLibrary)
    }

}
