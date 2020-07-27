//
//  MethodCell.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-04.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit

class MethodCell: UITableViewCell {
        
    @IBOutlet weak var methodImageView: UIImageView!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    

        func setMethod(method : Methods) {
            methodImageView.image = method.stepImage
            methodLabel.text = method.description
            stepLabel.text = method.step
        }
        
        
    }

