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
    @IBOutlet weak var copyText: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var saveDataPressed: UIButton!
    @IBOutlet weak var stringTest: UITextView!
    @IBOutlet weak var imageTest: UIImageView!
    var imagePicker = UIImagePickerController()
    var base64String: String!
    var authUI: FUIAuth!
    var usedImage: UIImage!
    var datas: DataInfo!
    var grayscale = false
    var language = "eng"
    var lanrow = 0
    var titleString = ""
    
    let keyList = ["edcc2f24f588957","4dcb87626888957","3cb6c3f6f688957","db0496663c88957"]
    var currKey = 0
    var key = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        self.copyText.isHidden = true
        self.copyText.isEnabled = true
        self.copyText.setTitle("Copy Text", for: .normal)
        self.saveDataPressed.isHidden = true
        self.saveDataPressed.isEnabled = true
        self.stringTest.textAlignment = NSTextAlignment.center
        self.textLabel.isHidden = true
        if datas == nil {
            datas = DataInfo()
        }
    }
    
    // Be sure to call this from viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
        print("current api key: \(currKey)")
        //self.saveDataPressed.titleLabel?.text = "Save Data"
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
            //print("signed in!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue"{
            let destination = segue.destination as! UINavigationController
            let settings = destination.viewControllers.first as! SettingsController
            settings.grayscale = grayscale
            settings.language = language
            settings.rownum = lanrow
        } else{
            print("***Ooppsies")
        }
    }
    
    @IBAction func unwindFromResult(segue: UIStoryboardSegue){
        print("unwind from result")
    }
    
    @IBAction func unwindFromSettings(segue: UIStoryboardSegue){
        print("unwind")
        let sourceViewController = segue.source as! SettingsController
        grayscale = sourceViewController.grayscale
        language = sourceViewController.language
        lanrow = sourceViewController.rownum
        if sourceViewController.changeKey == true{
            if currKey == 3{
                currKey = 0
            } else{
                currKey+=1
            }
        }
    }
    
    @IBAction func settingsPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "settingsSegue", sender: self)
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out!")
            signIn()
        } catch {
            print("*** ERROR: Couldn't sign out")
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        usedImage = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        
        //var numberOfLines = 0
        var rawText = ""
        
        //convert selected image to base64
        var strBase64 = ""
        //Convert to Black And White
        let noirImage = usedImage.noir
        let noirData = noirImage?.jpeg(.lowest)
        let imageData = usedImage.jpeg(.lowest)
        if grayscale == true{
            strBase64 = noirData!.base64EncodedString(options: .lineLength64Characters)
            print("*** Image converted to grayscale")
        } else{
            strBase64 = imageData!.base64EncodedString(options: .lineLength64Characters)
        }
        print("*** Language: \(language)")
        
        base64String = "data:image/jpeg;base64,"+strBase64
        print("*** Base64 Char Length: \(base64String.count)")
        self.datas.lang = self.language
        self.datas.image = strBase64
        //upload to OCR api and get response
        key = keyList[currKey]
        let URL = "https://api.ocr.space/parse/image"
        self.stringTest.text = ""
        Alamofire.upload(
            multipartFormData : { multipartFormData in
                multipartFormData.append(self.key.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "apikey")
                multipartFormData.append(self.base64String.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "base64Image")
                multipartFormData.append(self.language.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "language")
                multipartFormData.append("false".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "isOverlayRequired")
            },
            to: URL,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON{ response in
                        switch response.result{
                        case .success(let value):
                            let json = JSON(value)
                            //print(json)
                            rawText = json["ParsedResults"][0]["ParsedText"].stringValue
                            if rawText == ""{
                                self.showAlert(title: "No Words Detected", message: "No words were detected in this image. Check language settings and try again.")
                                break
                            }
                            self.stringTest.text = rawText
                            print("The raw text is:\n\(rawText)")
                        case .failure(let error):
                            print("*** JSON UPLOAD ERROR: \(error)")
                            if error._code == NSURLErrorTimedOut {
                                print("Request timeout!")
                                if self.currKey == 4{
                                    self.currKey = 0
                                } else {
                                    self.currKey+=1
                                }
                            }
                            self.stringTest.text = "ERROR! Check Console for Details"
                        }
                    }
                case .failure(let encodingError):
                    print("*** ENCODING ERROR: \(encodingError)")
                    self.stringTest.text = "ERROR! Check Console for Details"
                }
            }
        )
        if self.stringTest.text==""{
            self.stringTest.text = "LOADING..."
        }
        self.copyText.isHidden = false
        self.copyText.isEnabled = true
        self.copyText.setTitle("Copy Text", for: .normal)
        self.textLabel.isHidden = false
        self.stringTest.textAlignment = NSTextAlignment.left
        self.saveDataPressed.isHidden = false
        self.saveDataPressed.isEnabled = true
        imageTest.image = usedImage
        
        picker.dismiss(animated: true, completion: nil)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func copyTextPressed(_ sender: UIButton) {
        UIPasteboard.general.string = self.stringTest.text
        copyText.setTitle("Copied!", for: .normal)
        copyText.isEnabled = false
    }
    
    func showAlert(title: String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func saveAlert() {
        let alertController = UIAlertController(title: "Save Data", message: "Please enter a title for this transcription:", preferredStyle: .alert)
        alertController.addTextField{ (textField) in
            textField.text = "Untitled"
        }
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alertController] (_) in
            let textField = alertController!.textFields![0] // Force unwrapping because we know it exists.
            self.saveDataPressed.isEnabled = false
            if textField.text == ""{
                self.datas.name = "Untitled"
            } else{
                self.datas.name = textField.text!
            }
            self.datas.text = self.stringTest.text
            print("*** \(self.datas.text)")
            print("*** \(self.datas.lang)")
            print("*** \(self.datas.name)")
            print("*** \(self.datas.image.count)")
            self.datas.saveData { success in
                if success{
                    print("*** data saved!!!")
                } else{
                    print("data not saved")
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        saveAlert()
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
        //performSegue(withIdentifier: "savedSegue", sender: self)
    }
    
    
}

extension ViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
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
        logoImageView.image = UIImage(named: "title")
        logoImageView.contentMode = .scaleAspectFit // Set imageView to Aspect Fit
        loginViewController.view.addSubview(logoImageView) // Add ImageView to the login controller's main view
        return loginViewController
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
    }
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}
