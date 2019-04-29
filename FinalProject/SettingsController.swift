//
//  SettingsController.swift
//  FinalProject
//
//  Created by user150978 on 4/28/19.
//  Copyright © 2019 Tion. All rights reserved.
//

import UIKit

class SettingsController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch languageData[row] {
        case "English":
            language = "eng"
            rownum = 0
        case "Arabic":
            language = "ara"
            rownum = 1
        case "Chinese(Simplified)":
            language = "chs"
            rownum = 2
        case "Chinese(Traditional)":
            language = "cht"
            rownum = 3
        case "French":
            language = "fre"
            rownum = 4
        case "German":
            language = "ger"
            rownum = 5
        case "Greek":
            language = "gre"
            rownum = 6
        case "Korean":
            language = "kor"
            rownum = 7
        case "Italian":
            language = "ita"
            rownum = 8
        case "Japanese":
            language = "jpn"
            rownum = 9
        case "Russian":
            language = "rus"
            rownum = 10
        case "Spanish":
            language = "spa"
            rownum = 11
        default:
            language = "eng"
            rownum = 0
        }
        return languageData[row]
    }
    
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var graySwitch: UISwitch!
    @IBOutlet weak var apiSwitch: UISwitch!
    
    var languageData = ["English", "Arabic", "Chinese(Simplified)", "Chinese(Traditional)", "French", "German", "Greek", "Korean", "Italian", "Japanese", "Russian", "Spanish"]
    
    var grayscale = false
    var language = "eng"
    var rownum = 0
    var changeKey = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.languagePicker.delegate = self
        self.languagePicker.dataSource = self
        changeKey = false
        if grayscale == false{
            graySwitch.setOn(false, animated: true)
        } else{
            graySwitch.setOn(true, animated: true)
        }
        languagePicker.selectRow(rownum, inComponent:0, animated:true)
    }
    
    @IBAction func grayscalePressed(_ sender: UISwitch) {
        if graySwitch.isOn{
            graySwitch.setOn(false, animated: true)
            grayscale = false
        } else{
            graySwitch.setOn(true, animated: true)
            grayscale = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindSettings" {
            print("preparing from settings")
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func apiPressed(_ sender: UISwitch) {
        if apiSwitch.isOn{
            apiSwitch.setOn(false, animated: true)
            changeKey = false
        } else{
            apiSwitch.setOn(true, animated: true)
            changeKey = true
        }
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        languagePicker.selectRow(0, inComponent: 0, animated: true)
        graySwitch.setOn(false, animated: true)
        grayscale = false
        apiSwitch.setOn(false, animated: true)
        changeKey = false
        language = "eng"
    }
    
}
