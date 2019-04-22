//
//  ViewController.swift
//  FinalProject
//
//  Created by user150978 on 4/21/19.
//  Copyright © 2019 Tion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FirebaseUI
import Firebase
import GoogleSignIn

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var stringTest: UITextView!
    @IBOutlet weak var imageTest: UIImageView!
    var imagePicker = UIImagePickerController()
    var base64String: String!
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
    }
    
    // Be sure to call this from viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    // Nothing should change unless you add different kinds of authentication.
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
        } else {
            print("signed in!")
        }
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out!")
            //tableView.isHidden = true
            signIn()
        } catch {
            //tableView.isHidden = true
            print("*** ERROR: Couldn't sign out")
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        var resultText = ""
        var numberOfLines = 0
        var rawText = ""
        
        //convert selected image to base64
        let imageData:NSData = selectedImage.pngData()! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        base64String = "data:image/jpg;base64,"+strBase64
        
        //upload to OCR api and get response
        let URL = "https://api.ocr.space/Parse/Image"
        Alamofire.upload(
            multipartFormData : { multipartFormData in
                multipartFormData.append("eng".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "language")
                multipartFormData.append("true".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "isOverlayRequired")
                multipartFormData.append(self.base64String.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "base64Image")
                multipartFormData.append("4dcb87626888957".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "apikey")
            },
            to: URL,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON{ response in
                        switch response.result{
                        case .success(let value):
                            let json = JSON(value)
                            rawText = json["ParsedResults"][0]["ParsedText"].stringValue
                            if rawText == ""{
                                self.showAlert(title: "No Words Detected", message: "No words were detected in this image. Check language settings and try again.")
                                break
                            }
                            self.stringTest.text = rawText
                            print("The raw text is:\n\(rawText)")
                            numberOfLines = json["ParsedResults"][0]["TextOverlay"]["Lines"].count
                            print("There are \(numberOfLines) lines.")
                            //iterate through lines maybe
                        case .failure(let error):
                            print(error)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
                
            }
        )
        
        imageTest.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func takePic(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            
            imagePicker.delegate = self
            
            present(imagePicker, animated: true, completion: nil)
        } else{
            showAlert(title: "Camera Not Available", message: "There is no camera available on this device")
        }

    }
    
    @IBAction func choosePic(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func viewSaved(_ sender: UIButton) {
    }
}

extension ViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            // Assumes data will be isplayed in a tableView that was hidden until login was verified so unauthorized users can't see data.
            //tableView.isHidden = false
            print("^^^ We signed in with the user \(user.email ?? "unknown e-mail")")
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        
        // Create an instance of the FirebaseAuth login view controller
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        // Set background color to white
        loginViewController.view.backgroundColor = UIColor.white
        
        // Create a frame for a UIImageView to hold our logo
        let marginInsets: CGFloat = 16 // logo will be 16 points from L and R margins
        let imageHeight: CGFloat = 225 // the height of our logo
        let imageY = self.view.center.y - imageHeight // places bottom of UIImageView in the center of the login screen
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets*2), height: imageHeight)
        
        // Create the UIImageView using the frame created above & add the "logo" image
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit // Set imageView to Aspect Fit
        loginViewController.view.addSubview(logoImageView) // Add ImageView to the login controller's main view
        return loginViewController
    }
}

