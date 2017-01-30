//
//  CustomCellCPMTVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/30/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class CustomCellCPMTVC: UITableViewCell {
    
    @IBOutlet weak var imagePay: UIImageView!
    @IBOutlet weak var paymentNameLabel: UILabel!
    @IBOutlet weak var btn_Set: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Set(_ sender: UIButton) {
        //update total price label, send notification to CartViewVC
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "btnSetPressed"), object: nil)
    }

}
