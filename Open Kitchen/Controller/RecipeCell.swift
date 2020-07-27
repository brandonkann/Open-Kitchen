//
//  RecipeCell.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-11.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit

class RecipeCell: UITableViewCell {

    @IBOutlet weak var methodImage: UIImageView!
    @IBOutlet weak var methodText: UILabel!
    @IBOutlet weak var stepNumberLabel: UILabel!
    
    func setRecipeMethods(method : RecipeMethods) {
        methodImage.image = method.image
        methodText.text = method.description
          }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
