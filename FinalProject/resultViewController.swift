//
//  resultViewController.swift
//  FinalProject
//
//  Created by user150978 on 4/28/19.
//  Copyright © 2019 Tion. All rights reserved.
//

import UIKit

class resultViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var resultText: UITextView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var resultImage: UIImageView!
    
    var image: UIImage?
    var restext: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultImage.image = image
        resultText.text = "hello this is tim"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        resultImage.image = image
        resultText.text = "hello this is tim"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindResult" {
            print("preparing from result")
        }
    }

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
