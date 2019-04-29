//
//  DataInfo.swift
//  FinalProject
//
//  Created by user150978 on 4/28/19.
//  Copyright © 2019 Tion. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class DataInfo: NSObject{
    var name: String
    //var image: UIImage
    var image: String
    var text: String
    var lang: String
    var postingUserID: String
    var documentID: String
    //var documentUUID: String
    
    var dictionary: [String: Any] {
        return ["name": name, "image": image, "text": text, "lang": lang, "postingUserID": postingUserID]
    }
    
    init(name: String, image: String, text: String, lang: String, postingUserID: String, documentID: String) {
        self.name = name
        self.image = image
        self.text = text
        self.lang = lang
        self.postingUserID = postingUserID
        self.documentID = documentID
        //self.documentUUID = documentUUID
    }
    
    convenience override init(){
        self.init(name: "", image: "", text: "", lang: "", postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]){
        let name = dictionary["name"] as! String? ?? ""
        let image = dictionary["image"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let lang = dictionary["lang"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(name: name, image: image, text: text, lang: lang, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        //let storage = Storage.storage()
//        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
//            print("*** ERROR: Could not convert image to data format")
//            return completed(false)
//        }
        guard let postingUserID = (Auth.auth().currentUser?.uid) else{
            print("Error: Could not save data, no valid postingUserID")
            return completed(false)
        }
        //documentUUID = UUID().uuidString
        self.postingUserID = postingUserID
//        let storageRef = storage.reference().child(self.documentID)
//        let uploadTask = storageRef.putData(photoData)
        let dataToSave = self.dictionary
        if self.documentID != "" {
            let ref = db.collection("datas").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error{
                    print("Error: updating document")
                    completed(false)
                } else {
                    print("document updated")
                    completed(true)
                }
            }
        } else{
            var ref: DocumentReference? = nil
            ref = db.collection("datas").addDocument(data: dataToSave) { error in
                if let error = error{
                    print("Error: creating document")
                    completed(false)
                } else {
                    print("document created")
                    self.documentID = ref!.documentID
                    completed(true)
                }
            }
        }
    }
    
    func deleteData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("datas").document(self.documentID).delete() { error in
            if let error = error {
                print("*** ERROR: deleting review document ID \(self.documentID) \(error.localizedDescription)")
                completed(false)
            } else {
                completed(true)
            }
        }
    }
    
}
