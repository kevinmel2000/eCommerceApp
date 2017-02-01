//
//  HomeTVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 2/1/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class HomeTVC: UITableViewCell {
    
    @IBOutlet weak var imageProd: UIImageView!
    @IBOutlet weak var prodNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
