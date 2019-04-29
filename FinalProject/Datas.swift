//
//  Datas.swift
//  FinalProject
//
//  Created by user150978 on 4/29/19.
//  Copyright © 2019 Tion. All rights reserved.
//

import Foundation
import Firebase

class Datas{
    var dataArray = [DataInfo]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    func loadData(completed: @escaping () -> ())  {
        db.collection("datas").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.dataArray = []
            // there are querySnapshot!.documents.count documents in teh spots snapshot
            let postingUserID = Auth.auth().currentUser?.uid
            for document in querySnapshot!.documents {
                let spot = DataInfo(dictionary: document.data())
                if (spot.postingUserID == postingUserID) {
                    spot.documentID = document.documentID
                    self.dataArray.append(spot)
                }
            }
            completed()
        }
    }
}
