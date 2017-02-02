//
//  ChoicesPayMethodTVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/30/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class ChoicesPayMethodTVC: UITableViewController {
    
    let methods = ["COD", "Bank Transfer"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Payment Method List"
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //update total price label, get notification from CutomTableViewCell
        //NotificationCenter.default.addObserver(self, selector: #selector(ChoicesPayMethodTVC.BtnSet), name: NSNotification.Name(rawValue: "btnSetPressed"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.methods.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110.0;//Choose your custom row height
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoicesMethodCell", for: indexPath) as! CustomCellCPMTVC

        cell.paymentNameLabel.text = methods[indexPath.row]
        cell.accessoryView = cell.btn_Set
        cell.isUserInteractionEnabled = false
        cell.btn_Set.addTarget(self, action: #selector(ChoicesPayMethodTVC.BtnSet(_:)), for: UIControlEvents.touchUpInside)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let rowNumber = (tableView.cellForRow(at: indexPath)?.tag)!
        let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Button Set in cell number \(rowNumber) is pressed", preferredStyle: UIAlertControllerStyle.alert)
        alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  nil))
        self.present(alertStatus, animated: true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func BtnSet(_ sender:UIButton) {
        let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Button Set is pressed", preferredStyle: UIAlertControllerStyle.alert)
        alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  nil))
        self.present(alertStatus, animated: true, completion: nil)
    }

}
