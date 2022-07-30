//
//  ViewController.swift
//  Meme 1.0
//
//  Created by Joab Maldonado on 7/10/22.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navigationBar: UIToolbar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialView()
    }
    
    //for the initial view and cancel sharing the meme
    func setInitialView(){
        setupTextField(textField: topTextField, text: "TOP")
        setupTextField(textField: bottomTextField, text: "BOTTOM")
        imagePickerView.image = nil
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
        
    }
    
    //method to set properties of the text fields
    func setupTextField(textField: UITextField, text: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = text
        textField.textAlignment = .center
        textField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: Text field behavior
    
    //clears the textfield when the user starts typing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextField && textField.text == "TOP" || textField == bottomTextField && textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    //dismisses the keyboard when the return button is selected by the user
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //defines the textfield attributes programatically
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -4.0
    ]
    
    //MARK: keboard behavior
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        //removes both observers at once
        NotificationCenter.default.removeObserver(self)
    }
    
    //keeps the keyboard from covering the input field by removing the height of the keyboard from the views frame.  Only needed on the bottom text.
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    //resets the frame height
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //MARK: Action selectors
    
    //image picker is presented with access to the photo library
    @IBAction func pickAnImage(_ sender: Any) {
        pickImage(source: .photoLibrary)
    }
    
    //image picker access is presented with access to the camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImage(source: .camera)
    }
    
    func pickImage(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
        }
    
    @IBAction func shareMeme(_ sender: Any){
        let image = generateMemedImage()
        
        //brings the generated meme to the activity view and presents activity view sharing options
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
        //saves the meme to the Meme Struct when the meme is saved in the activityview
        activityController.completionWithItemsHandler = {(_, completed, _, _) in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //resets the view when the user chooses to stop working with the meme
    @IBAction func cancelMeme(_sender: Any) {
        setInitialView()
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imagePickerView.image = image
            } else {
                print("error")
            }
            
            //enable share and cancel buttons after picking an image
            shareButton.isEnabled = true
            cancelButton.isEnabled = true
            
            dismiss(animated: true, completion: nil)
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Meme Model
    
    //The Meme struct is a model (see Meme file) used by this ViewController.
    
    //create and save the Meme.
    func save() {
        let meme  = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {
        
        //removes the nav and toolbar from the saved meme
        navigationBar.isHidden = true
        toolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //unhides the bars after the image is captured
        navigationBar.isHidden = false
        toolbar.isHidden = false
        
        return memedImage
    }
    
    
}


