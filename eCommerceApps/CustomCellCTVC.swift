//
//  CustomCellCTVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 2/2/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class CustomCellCTVC: UITableViewCell {

    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var label_shippingCourier: UILabel!
    @IBOutlet weak var label_serviceName: UILabel!
    @IBOutlet weak var label_estCost: UILabel!
    @IBOutlet weak var label_etd: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
