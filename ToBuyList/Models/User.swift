//
//  Database.swift
//  ToBuyList
//
//  Created by administrator on 12/01/2022.
//

import Firebase

struct User {
    let uid : String
    let email : String
    
    init(authData : Firebase.User){
        uid = authData.uid
        email = authData.email ?? ""
    }
    
    init(uid: String, email: String){
        self.uid = uid
        self.email = email
    }
}
