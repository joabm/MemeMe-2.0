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
        
        //Set the text field delegates
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
        
        //set text field attribites
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        setInitialView()
    }

    //for the initial view and cancel sharing the meme
    func setInitialView(){
        topTextField.text = "TOP"
        topTextField.textAlignment = .center
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = .center
        imagePickerView.image = nil
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
        
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

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    //image picker access is presented with access to the camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: Any){
        let image = generateMemedImage()
        
        //brings the generated meme to the activity view and presents activity view sharing options
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
        //saves the meme to the Meme Struct when the meme is saved in the activityview
        activityController.completionWithItemsHandler = {(activity, completed, items, error) in
            if completed {
                self.save()
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
    
    //Meme holder
    struct Meme {
        let topText: String
        let bottomText: String
        let originalImage:UIImage
        let memedImage:UIImage
    }
    
    //create and save the Meme
    func save() {
        _  = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
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


