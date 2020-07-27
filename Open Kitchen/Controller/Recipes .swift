//
//  Recipes.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-01.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit

class Recipes {
    var image : UIImage
    var title : String
    var rating: String
    var time : String
    
    init(image: UIImage, title: String, rating: String, time : String) {
        self.image = image
        self.title = title
        self.rating = rating
        self.time = time
    }
}
