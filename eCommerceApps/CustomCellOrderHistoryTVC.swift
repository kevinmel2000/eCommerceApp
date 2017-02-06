//
//  CustomCellOrderHistoryTVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 2/7/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class CustomCellOrderHistoryTVC: UITableViewCell {
    
    @IBOutlet weak var inv_number: UILabel!
    @IBOutlet weak var created_date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
