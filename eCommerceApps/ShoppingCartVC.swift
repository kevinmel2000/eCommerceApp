//
//  ShoppingCartVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/26/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class ShoppingCartVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let userdefault = UserDefaults.standard
    let cart = Gorobak.sharedInstance
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var totalCostsLabel: UILabel!
    @IBOutlet weak var CheckOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Shopping Cart"

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkEmptyStateOfCart()
        tableView.reloadData()
        
        updateTotalCostsLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //update total price label, get notification from CutomTableViewCell
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingCartVC.updateTotalCostsLabel), name: NSNotification.Name(rawValue: "ItemPriceHasBeenChanged"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.numberOfItemsInCart()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productCell = tableView.dequeueReusableCell(withIdentifier: "SCartCell", for: indexPath as IndexPath) as! CustomCellShoppingCartVC
        
        productCell.selectionStyle = .none
        
        let product = cart.productAtIndexPath(indexPath)
        productCell.imageProd.downloadedFrom(link: product.imageURL)
        productCell.imageProd.contentMode = UIViewContentMode.scaleAspectFit
        productCell.itemNameLabel.text = product.prodName
        productCell.itemNameLabel.sizeToFit()
        productCell.itemPriceLabel.text = product.prodPrice //productPriceFormatter.string(from: Int(product.prodPrice)! as NSNumber)
        productCell.itemPriceLabel.sizeToFit()
        //productCell.accessoryView = productCell.itemPriceLabel
        productCell.itemQty.text = String(product.qty)
        productCell.itemQty.sizeToFit()
        productCell.Stepper.layer.cornerRadius = 5
        productCell.Stepper.maximumValue = Double(product.stock)!
        
        return productCell
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
     }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 134.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = cart.productAtIndexPath(indexPath as IndexPath)
            let successful = cart.removeProduct(product)
            
            if (successful) {
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath as IndexPath], with: .right)
                tableView.endUpdates()
            }
            
            checkEmptyStateOfCart()
        }
    }
    
    func checkEmptyStateOfCart() {
        setEmptyViewVisible(visible: cart.numberOfItemsInCart() == 0)
    }
    
    func updateTotalCostsLabel() {
        totalCostsLabel.text = "IDR "+String(cart.totalPriceInCart())
    }
    
    func clearCart() {
        cart.deleteAllDataInCart()
        tableView.reloadData()
        
        setEmptyViewVisible(visible: true)
    }
    
    func setEmptyViewVisible(visible: Bool) {
        emptyView.isHidden = !visible
        if visible {
            clearButton.isEnabled = false
            CheckOutButton.isEnabled = false
            CheckOutButton.backgroundColor = UIColor.darkGray
            self.view.bringSubview(toFront: emptyView)
        } else {
            clearButton.isEnabled = true
            CheckOutButton.isEnabled = true
            CheckOutButton.backgroundColor = UIColor(red: 116.0/255.0, green: 252.0/255.0, blue: 50.0/255.0, alpha: 1.0)
            self.view.sendSubview(toBack: emptyView)
        }
    }
    
    @IBAction func clearButton(_ sender: UIBarButtonItem) {
        let alertClear = UIAlertController (title: "DSC App Message", message: "All products in shopping cart will be deleted. Are you sure to continue?", preferredStyle: UIAlertControllerStyle.alert)
        alertClear.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  {(action) in
            self.clearCart()
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.checkEmptyStateOfCart()
                self.updateTotalCostsLabel()
            })
        }))
        alertClear.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive,handler:  nil))
        self.present(alertClear, animated: true, completion: nil)
    }
    
    @IBAction func CheckOutButton(_ sender: UIButton) {
        if ((userdefault.object(forKey: "loginStatus") as? Bool != nil) && (userdefault.object(forKey: "userid") as? String != nil)) {
            if (userdefault.object(forKey: "loginStatus") as? Bool != false) {
                performSegue(withIdentifier: "SegueFromCartToShipment", sender: self)
            }
        } else {
            let alertStatus = UIAlertController (title: "DSC App Message", message: "Please login to start check out process.", preferredStyle: UIAlertControllerStyle.alert)
            alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  nil))
            self.present(alertStatus, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImageView {
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
}
