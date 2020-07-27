//
//  Ingredient .swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-02.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import Foundation
import Firebase


struct Ingredient {
    var ingredient : String
    
    let messageSender = Auth.auth().currentUser?.email
//    var dictionary: [String: Any] {
//          return ["name": ingredient,
//                  "amount": amount]
//      }

    init(ingredient : String) {
        self.ingredient = ingredient
    
    }
}
