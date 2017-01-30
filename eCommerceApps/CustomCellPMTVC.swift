//
//  CustomCellPMTVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/30/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class CustomCellPMTVC: UITableViewCell {
    
    @IBOutlet weak var imagePay: UIImageView!
    @IBOutlet weak var paymentNameLabel: UILabel!
    @IBOutlet weak var SW_defaultPay: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func SW_defaultPay(_ sender: UISwitch) {
        //update total price label, send notification to CartViewVC
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "defaultPaymentHasBeenChanged"), object: nil)
    }
    
}
