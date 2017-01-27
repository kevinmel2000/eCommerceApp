//
//  CustomCellShoppingCartVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/27/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class CustomCellShoppingCartVC: UITableViewCell {

    @IBOutlet weak var imageProd: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemQty: UILabel!
    @IBOutlet weak var Stepper: UIStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func Stepper_ValChanged(_ sender: UIStepper) {
        
        self.itemQty.text = String(Int(sender.value))
        self.itemQty.sizeToFit()
        //update product qty in cart
        Gorobak.sharedInstance.updateProductQty(self.itemNameLabel.text!, newQty: Int(sender.value))
        //update total price label, send notification to CartViewVC
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ItemPriceHasBeenChanged"), object: nil)
    }
    

}
