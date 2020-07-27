//
//  RecipeMethods.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-11.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import Foundation
import UIKit


//struct RecipeMethods {
//    var description : String
//
////    var dictionary: [String: Any] {
////          return ["name": ingredient,
////                  "amount": amount]
////      }
//
//    init(description : String) {
//        self.description = description
//
//    }
//}
class RecipeMethods {
    var image : UIImage
    var description : String
    var date : String
    
    init(image: UIImage, description: String, date: String) {
        self.image = image
        self.description = description
        self.date = date
    }
}
