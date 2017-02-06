//
//  CourierTVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 2/2/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class CourierTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct UserProfile: Decodable{
        let UserAddr_street: String?
        let UserAddr_city: String?
        let UserAddr_province: String?
        let UserAddr_country: String?
        let UserAddr_postalCode: String?
        
        init?(json: JSON){
            self.UserAddr_street = "street" <~~ json
            self.UserAddr_city = "city" <~~ json
            self.UserAddr_province = "province" <~~ json
            self.UserAddr_country = "country" <~~ json
            self.UserAddr_postalCode = "postalcode" <~~ json
        }
    }
    
    struct courierList: Decodable{
        let logo: String?
        let shipper: String?
        let service: String?
        let cost: Int?
        let etd: String?
        
        init?(json: JSON){
            self.logo = "logo" <~~ json
            self.shipper = "shipper" <~~ json
            self.service = "service" <~~ json
            self.cost = "cost" <~~ json
            self.etd = "etd" <~~ json
        }
    }
    
    struct CreateInvoice: Decodable {
        let status: String?
        let message: String?
        
        init?(json: JSON) {
            self.status = "status" <~~ json
            self.message = "message" <~~ json
        }
    }
    
    var TableData = [String:Any]()
    let userdefault = UserDefaults.standard
    let cart = Gorobak.sharedInstance
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCost: UILabel!
    @IBOutlet weak var btn_checkOut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Courier/Shipper"
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        get_data_user_addr(url:"https://imperio.co.id/project/ecommerceApp/userprofile.php")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*if User_city.text! != "City"{
         get_data_from_url(url: "https://www.imperio.co.id/project/ecommerceApp/CourierDataReq.php")
         }*/
        updateTotalCostsLabel()
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
        if !TableData.isEmpty {
            guard let value = TableData as? JSON,
                let eventsArrayJSON = value["ShipperResult"] as? [JSON]
                else { fatalError() }
            let CourierList = [courierList].from(jsonArray: eventsArrayJSON)
            return CourierList!.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 134.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourierCell", for: indexPath) as! CustomCellCTVC
        cell.selectionStyle = .blue
        
        if !TableData.isEmpty {
            guard let value = TableData as? JSON,
                let eventsArrayJSON = value["ShipperResult"] as? [JSON]
                else { fatalError() }
            let CourierList = [courierList].from(jsonArray: eventsArrayJSON)
            cell.ImageView.downloadedFrom(link: (CourierList?[indexPath.row].logo!)!)
            cell.label_shippingCourier.text = CourierList?[indexPath.row].shipper!
            cell.label_shippingCourier.sizeToFit()
            cell.label_serviceName.text = CourierList?[indexPath.row].service!
            cell.label_serviceName.sizeToFit()
            cell.label_estCost.text = cart.getCurrencyCode()+" "+String(describing: (CourierList?[indexPath.row].cost!)!)
            cell.label_estCost.sizeToFit()
            if (CourierList?[indexPath.row].etd! == "") {
                cell.label_etd.text = "ETD data is not available"
            } else {
                cell.label_etd.text = "\((CourierList?[indexPath.row].etd!)!) Day(s)"
            }
            cell.label_etd.sizeToFit()
            
        } else {
            cell.label_shippingCourier.text = "Courier name is not available"
            cell.label_shippingCourier.sizeToFit()
            cell.label_serviceName.text = "Service type is not available"
            cell.label_serviceName.sizeToFit()
            cell.label_estCost.text = "Price is not available"
            cell.label_estCost.sizeToFit()
            cell.label_etd.text = "ETD data is not available"
            cell.label_etd.sizeToFit()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)! as! CustomCellCTVC
        currentCell.backgroundColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1.0)
        if(((currentCell.label_estCost.text) != "") && ((currentCell.label_estCost.text) != nil)){
            cart.AddShippingCost(currentCell.label_shippingCourier.text!, service:currentCell.label_serviceName.text!, cost: currentCell.label_estCost.text!)
        }
        updateTotalCostsLabel()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func btn_checkOut(_ sender: UIButton) {
        if (cart.getShippingCost() != 0){
            let alert1 = UIAlertController (title: "DSC App Message", message: "Are you sure want to check out?", preferredStyle: UIAlertControllerStyle.alert)
            alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:{(action) in
                self.createInvoice(paymentType: "Bank Transfer")
            }))
            alert1.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive,handler:nil))
            self.present(alert1, animated: true, completion: nil)
        } else {
            let alert = UIAlertController (title: "DSC App Message", message: "Please select a courier service company.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func get_data_user_addr(url:String){
        let parameterURL = ["userid":self.userdefault.object(forKey: "userid") as! String]
        Alamofire.request(url, parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
            let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
            alert.view.tintColor = UIColor.black
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(frame: CGRect(x: (self.view.frame.size.width/2),y: (self.view.frame.size.height)/2,width: (self.view.frame.size.width)*0.4,height: (self.view.frame.size.height)*0.4))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            
            switch response.result{
            case .success(let data):
                self.dismiss(animated: false, completion: nil)
                guard let value = data as? JSON,
                    let eventsArrayJSON = value["userprof"] as? [JSON]
                    else { fatalError() }
                let Userprofile = [UserProfile].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((Userprofile?.count)!) {
                    self.get_data_from_url(url: "https://www.imperio.co.id/project/ecommerceApp/CourierDataReq.php", city: (Userprofile?[j].UserAddr_city!)!)
                }
                break
            case .failure(let error):
                self.dismiss(animated: false, completion: nil)
                print("Error: \(error)")
                let alert = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    //untuk ngambil data dari server
    func get_data_from_url(url:String, city:String){
        self.TableData.removeAll(keepingCapacity: false)
        let parameterURL = ["dest":city,"weight":String(cart.totalWeightInCart())]
        Alamofire.request(url, parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
            let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
            alert.view.tintColor = UIColor.black
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(frame: CGRect(x: (self.view.frame.size.width/2),y: (self.view.frame.size.height)/2,width: (self.view.frame.size.width)*0.4,height: (self.view.frame.size.height)*0.4))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            
            switch response.result{
            case .success(let data):
                self.dismiss(animated: false, completion: nil)
                self.TableData = data as! JSON
                //print(self.TableData)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                break
            case .failure(let error):
                self.dismiss(animated: false, completion: nil)
                print("Error: \(error)")
                let alert = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    func updateTotalCostsLabel() {
        totalCost.text = String(cart.totalPriceInCart()+cart.getShippingCost())
    }
    
    func createInvoice(paymentType: String) {
        let valid = JSONSerialization.isValidJSONObject(cart.prepareForConvesionToJSON())
        if valid {
            if let productsJSON = try? JSONSerialization.data(withJSONObject: cart.prepareForConvesionToJSON(), options: .prettyPrinted) {
                let strJSON = String(bytes: productsJSON, encoding: .utf8)
                //let strJSONfinal = "\""+strJSON!+"\""
                let parameterURL=["userid":userdefault.object(forKey: "userid") as! String, "products":strJSON!,"subtotal":String(cart.totalPriceInCart()),"tax":String(cart.calculateTax(true)),"weight":String(cart.totalWeightInCart()),"shipper":String(cart.getShipperData().0),"shipperService":String(cart.getShipperData().1),"shippingCost":String(cart.getShippingCost()),"paymentMethod":paymentType]
                //print(parameterURL)
                Alamofire.request("https://www.imperio.co.id/project/ecommerceApp/createInvoice.php", parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
                    switch response.result{
                    case .success(let data):
                        guard let value = data as? JSON,
                            let eventsArrayJSON = value["InvoiceStatus"] as? [JSON]
                            else { fatalError() }
                        let createinvoice = [CreateInvoice].from(jsonArray: eventsArrayJSON)
                        for j in 0 ..< Int((createinvoice?.count)!) {
                            let alert = UIAlertController (title: "\((createinvoice?[0].status!)!) To Create Invoice", message: (createinvoice?[j].message!)!, preferredStyle: UIAlertControllerStyle.alert)
                            if (createinvoice?[j].status!)! == "Success" {
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: {action in
                                    self.cart.deleteAllDataInCart()
                                    self.performSegue(withIdentifier: "SegueFinishCheckOut", sender: self)
                                }))
                            } else {
                                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default,handler: nil))
                            }
                            self.present(alert, animated: true, completion: nil)
                        }
                        break
                    case .failure(let error):
                        let alert = UIAlertController (title: "Error", message: String(describing: error), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                }
            }
        }
    }

}
