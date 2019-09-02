//
//  User.swift
//  PipeLineChat
//
//  Created by Tuncay Cansız on 31.08.2019.
//  Copyright © 2019 Tuncay Cansız. All rights reserved.
//

import UIKit

//User's Model
//Kullanıcı Modeli
class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}
