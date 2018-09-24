//
//  CustomCell.swift
//  PennMobile-Challenge
//
//  Created by brian bae on 2018. 9. 22..
//  Copyright © 2018년 brian bae. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    //Variables for customcell -> check storyboard
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var hours: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
