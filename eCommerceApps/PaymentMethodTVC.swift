//
//  PaymentMethodTVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/30/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class PaymentMethodTVC: UITableViewController {

    //let TableData = ["Bank Transfer"]
    var TableData = [String:Any]()
    
    struct DefaultPayment: Decodable {
        var status: String?
        var method: String?
        var logo: String?
        
        init?(json: JSON) {
            status = "Status" <~~ json
            method = "default_payment" <~~ json
            logo = "logo" <~~ json
        }
    }
    
    let userdefault = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Payment Method"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        if ((userdefault.object(forKey: "loginStatus") as? Bool == nil) && (userdefault.object(forKey: "userid") as? String == nil)) {
            if (userdefault.object(forKey: "loginStatus") as? Bool == false) {
                let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Please log in to access this page.", preferredStyle: UIAlertControllerStyle.alert)
                alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  {(action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alertStatus, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        get_data_from_url(url: BaseURL.rootURL()+"getDefaultPayment.php")
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
        if !TableData.isEmpty{
            guard let value = TableData as? JSON,
                let eventsArrayJSON = value["paymentDefault"] as? [JSON]
                else { fatalError() }
            let defaultpayment = [DefaultPayment].from(jsonArray: eventsArrayJSON)
            return defaultpayment!.count
        } else {
            return 1
        }
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
        
        if !TableData.isEmpty{
            guard let value = TableData as? JSON,
                let eventsArrayJSON = value["paymentDefault"] as? [JSON]
                else { fatalError() }
            let defaultpayment = [DefaultPayment].from(jsonArray: eventsArrayJSON)
            cell.paymentNameLabel.text = defaultpayment?[indexPath.row].method
            cell.imagePay.downloadedFrom(link: (defaultpayment?[indexPath.row].logo!)!)
        } else {
            cell.paymentNameLabel.text = "Data is not available"
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SegueChoicesPaymentMethod", sender: self)
    }
    
    func get_data_from_url(url:String){
        let parameterURL = ["userid":self.userdefault.object(forKey: "userid") as! String]
        Alamofire.request(url, parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
            switch response.result{
            case .success(let data):
                self.TableData = data as! JSON
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

}
