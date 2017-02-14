//
//  ChoicesPayMethodTVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/30/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class ChoicesPayMethodTVC: UITableViewController {
    
    var methods = [String:Any]()
    
    struct paymentMethod: Decodable {
        var name: String?
        var logo: String?
        
        init?(json: JSON) {
            name = "payment_name" <~~ json
            logo = "payment_logo" <~~ json
        }
        
    }
    
    struct defaultStatus: Decodable {
        var status: String?
        
        init?(json: JSON) {
            status = "Status" <~~ json
        }
    }
    
    let userdefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Payment Method List"
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        get_data_from_url(url: BaseURL.rootURL()+"paymentsMethod.php")
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
        if !methods.isEmpty {
            guard let value = methods as? JSON,
                let eventsArrayJSON = value["payments"] as? [JSON]
                else { fatalError() }
            let paymentmethod = [paymentMethod].from(jsonArray: eventsArrayJSON)
            return paymentmethod!.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110.0;//Choose your custom row height
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoicesMethodCell", for: indexPath) as! CustomCellCPMTVC
        
        if !methods.isEmpty {
            guard let value = methods as? JSON,
                let eventsArrayJSON = value["payments"] as? [JSON]
                else { fatalError() }
            let paymentmethod = [paymentMethod].from(jsonArray: eventsArrayJSON)
            cell.imagePay.downloadedFrom(link: (paymentmethod?[indexPath.row].logo!)!)
            cell.paymentNameLabel.text = (paymentmethod?[indexPath.row].name!)!
            cell.paymentNameLabel.sizeToFit()
        } else {
            cell.paymentNameLabel.text = "Data is not available"
            cell.paymentNameLabel.sizeToFit()
        }
        
        cell.accessoryView = cell.btn_Set
        cell.btn_Set.tag = indexPath.row
        cell.accessoryView?.isUserInteractionEnabled = true
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        cell.btn_Set.addTarget(self, action: #selector(ChoicesPayMethodTVC.BtnSet(_:)), for: UIControlEvents.touchUpInside)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
    
    func get_data_from_url(url:String){
        //let parameterURL = ["userid":self.userdefault.object(forKey: "userid") as! String]
        Alamofire.request(url).validate(contentType: ["application/json"]).responseJSON{ response in
            
            switch response.result{
            case .success(let data):
                self.methods = data as! JSON
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                break
            case .failure(let error):
                
                print("Error: \(error)")
                let alert1 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert1, animated: true, completion: nil)
                break
            }
        }
    }
    
    /*override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let rowNumber = (tableView.cellForRow(at: indexPath)?.tag)!
        let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Button Set in cell number \(rowNumber) is pressed", preferredStyle: UIAlertControllerStyle.alert)
        alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  nil))
        self.present(alertStatus, animated: true, completion: nil)
    }*/

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
        let TagNumber = sender.tag
        var method = ""
        //print("Button Set Tag: \(TagNumber)")
        let indexPath = IndexPath(row: TagNumber, section: 0)
        let currentCell = tableView.cellForRow(at: indexPath)! as! CustomCellCPMTVC
        method = currentCell.paymentNameLabel.text!
        //print("method: \(method)")
        let parameterURL = ["userid":self.userdefault.object(forKey: "userid") as! String, "method":method]
        Alamofire.request(BaseURL.rootURL()+"setDefaultPayment.php", parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
            switch response.result{
            case .success(let data):
                guard let value = data as? JSON,
                    let eventsArrayJSON = value["paymentDefault"] as? [JSON]
                    else { fatalError() }
                let defaultstatus = [defaultStatus].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((defaultstatus?.count)!) {
                    let alertStatus = UIAlertController (title: "eCommerce App Message", message: "\((defaultstatus?[j].status!)!) to set default payment method", preferredStyle: UIAlertControllerStyle.alert)
                    alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  nil))
                    self.present(alertStatus, animated: true, completion: nil)
                }
                break
            case .failure(let error):
                print("Error: \(error)")
                let alert1 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert1, animated: true, completion: nil)
                break
            }
        }
    }

}
