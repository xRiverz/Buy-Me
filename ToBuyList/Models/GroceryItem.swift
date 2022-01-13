//
//  GroceryItem.swift
//  ToBuyList
//
//  Created by administrator on 12/01/2022.
//

import Firebase

struct GroceryItem {
    let ref: DatabaseReference?
    let key : String
    let name : String
    let addedByUser : String
    var completed : Bool
    
    //MARK : Initialize with Raw Data
    
    init(name : String, addedByUser: String, completed: Bool, Key: String = "") {
        self.ref = nil
        self.key = Key
        self.name =  name
        self.addedByUser = addedByUser
        self.completed = completed
    }
    
    //MARK : Initialize with Firebase DataSnapshot
    init?(snapshot: DataSnapshot){
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let addedByUser = value["addedByUser"] as? String,
            let completed = value["completed"] as? Bool
        else { return nil
        }
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
    }
    
    //MARK : Convert GroceryItme to AnyObject
    func toAnyObject() -> Any {
        return [
            "name" : name,
            "addedByUser": addedByUser,
            "completed": completed
        ]
    }
}
