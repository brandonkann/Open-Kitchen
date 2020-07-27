//
//  Methods.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-03.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import Foundation
import UIKit
import Firebase


struct Methods {
    var step : String
    var description : String
    var stepImage : UIImage?
    
    let messageSender = Auth.auth().currentUser?.email
    var mdictionary: [String: Any] {
          return ["step": step,
                  "description" : description ,
                  "user" : messageSender!]
      }
    
    var idictionary : [String : Any] {
        return ["Image" : stepImage!]
    }


    init(step : String, description : String, stepImage : UIImage) {
        self.step = step
        self.description = description
        self.stepImage = stepImage
    
    }
}
