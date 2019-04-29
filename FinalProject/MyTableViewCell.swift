//
//  MyTableViewCell.swift
//  FinalProject
//
//  Created by user150978 on 4/29/19.
//  Copyright © 2019 Tion. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    
    @IBOutlet weak var cellSub: UILabel!
    
    var lang = ""
    func configureCell(data: DataInfo){
        cellTitle.text = data.name
        switch data.lang {
        case "eng":
            lang = "English"
            
        case "ara":
            lang = "Arabic"
        case "chs":
            lang = "Chinese(Simplified)"
        case "cht":
            
            lang = "Chinese(Traditional)"
        case "fre":
            
            lang = "French"
        case "ger":
            
            lang = "German"
        case "gre":
            
            lang = "Greek"
        case "kor":
            
            lang = "Korean"
        case "ita":
            
            lang = "Italian"
        case "jpn":
            
            lang = "Japanese"
        case "rus":
            
            lang = "Russian"
        case "spa":
            
            lang = "Spanish"
        default:
            lang = "English"
        }
        cellSub.text = lang
    }

}
