//
//  TableDetailViewController.swift
//  FinalProject
//
//  Created by user150978 on 4/29/19.
//  Copyright © 2019 Tion. All rights reserved.
//

import UIKit
import SwiftGoogleTranslate

class TableDetailViewController: UIViewController {

    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var textLabel: UITextView!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var langLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var copyText: UIBarButtonItem!
    
    var dataInfo: DataInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        translateButton.isHidden = true
        translateButton.isEnabled = true
        titleLabel.text = dataInfo.name
        textLabel.text = dataInfo.text
        let strBase64 = dataInfo.image
        print(strBase64.count)
        let dataDecoded = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        imageLabel.image = decodedimage
        
        copyText.title = "Copy Text"
        copyText.isEnabled = true
        switch dataInfo.lang {
        case "eng":
            langLabel.text = "Transcribed From English"
        
        case "ara":
            langLabel.text = "Transcribed From Arabic"
        case "chs":
            langLabel.text = "Transcribed From Chinese(Simplified)"
        case "cht":
          
            langLabel.text = "Transcribed From Chinese(Traditional)"
        case "fre":
          
            langLabel.text = "Transcribed From French"
        case "ger":
       
            langLabel.text = "Transcribed From German"
        case "gre":
        
            langLabel.text = "Transcribed From Greek"
        case "kor":
     
            langLabel.text = "Transcribed From Korean"
        case "ita":
     
            langLabel.text = "Transcribed From Italian"
        case "jpn":
      
            langLabel.text = "Transcribed From Japanese"
        case "rus":
 
            langLabel.text = "Transcribed From Russian"
        case "spa":

            langLabel.text = "Transcribed From Spanish"
        default:
            langLabel.text = "Transcribed From English"
        }
        if dataInfo.lang != "eng"{
            translateButton.isHidden = false
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func copyTextPressed(_ sender: UIBarButtonItem) {
        UIPasteboard.general.string = self.textLabel.text
        copyText.title = "Copied!"
        copyText.isEnabled = false
    }
    @IBAction func translatePressed(_ sender: UIButton) {
        var langu = ""
        SwiftGoogleTranslate.shared.detect(self.textLabel.text!) { (detections, error) in
            if let detections = detections {
                for detection in detections {
                    print(detection.language)
                    langu = detection.language
                    
                }
            }
        }
        if langu != "en"{
            SwiftGoogleTranslate.shared.translate(self.textLabel.text!, "en", langu) { (text, error) in
                if let t = text {
                    print(t)
                    DispatchQueue.main.async {
                        self.textLabel.text = t
                    }
                }
            }
        } else {
            self.translateButton.setTitle("Text is already in English!", for: .normal)
        }
        self.translateButton.isEnabled = false
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        dataInfo.deleteData{ (success) in
            if success {
                print("Data Deleted")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("*** ERROR: Delte unsuccessful")
            }
        }
    }
    
}
