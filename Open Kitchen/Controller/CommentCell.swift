//
//  CommentCell.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-14.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var comments: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
