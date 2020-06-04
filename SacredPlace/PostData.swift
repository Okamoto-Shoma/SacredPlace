//
//  PostData.swift
//  SacredPlace
//
//  Created by 岡本 翔真 on 2020/06/01.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class PostData: NSObject {
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var location: GeoPoint?
    var geocoder: String?
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.self.documentID
        let postDic = document.self.data()
        self.name = postDic["name"] as? String
        self.caption = postDic["caption"] as? String
        guard let timestamp = postDic["date"] as? Timestamp else { return }
        self.date = timestamp.dateValue()
        self.location = postDic["location"] as? GeoPoint
        self.geocoder = postDic["geocoder"] as? String
    }
}
