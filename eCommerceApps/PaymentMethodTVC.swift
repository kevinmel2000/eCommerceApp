//
//  PaymentMethodTVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/30/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire

class PaymentMethodTVC: UITableViewController {

    let TableData = ["Bank Transfer"]
    //var TableData:Array<String> = Array <String>()
    
    let userdefault = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Payment Method"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        if ((userdefault.object(forKey: "loginStatus") as? Bool != nil) && (userdefault.object(forKey: "userid") as? String != nil)) {
            if (userdefault.object(forKey: "loginStatus") as? Bool != false) {
                get_data_from_url(url: BaseURL.rootURL()+"userprofile.php")
            }
        } else {
            let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Please log in to access this page.", preferredStyle: UIAlertControllerStyle.alert)
            alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  {(action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertStatus, animated: true, completion: nil)
        }
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
        return 1//TableData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110.0;//Choose your custom row height
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Default Method"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodCell", for: indexPath as IndexPath) as! CustomCellPMTVC
        
        cell.accessoryType = .disclosureIndicator
        cell.paymentNameLabel.text = TableData[indexPath.row]
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SegueChoicesPaymentMethod", sender: self)
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
    
    func get_data_from_url(url:String){
        //let queue = DispatchQueue(label: "com.luthfifr-queue", qos: .utility, attributes: [.concurrent])
        let parameterURL = ["userid":self.userdefault.object(forKey: "userid") as! String]
        Alamofire.request(url, parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
            switch response.result{
            case .success(let data):
                /*guard let value = data as? JSON,
                    let eventsArrayJSON = value["userprof"] as? [JSON]
                    else { fatalError() }
                let Userprofile = [UserProfile].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((Userprofile?.count)!) {
                    if (Userprofile?[j].UserName! != "None") {
                        self.user_name.text = (Userprofile?[j].UserName!)!
                        self.user_street.text = (Userprofile?[j].UserAddr_street!)!
                        self.user_city.text = (Userprofile?[j].UserAddr_city!)!
                        self.user_province.text = (Userprofile?[j].UserAddr_province!)!
                        self.user_country.text = (Userprofile?[j].UserAddr_country!)!
                        self.user_postalCode.text = (Userprofile?[j].UserAddr_postalCode!)!
                        self.user_mobileNumber.text = (Userprofile?[j].UserMobilePh!)!
                    }
                }*/
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
