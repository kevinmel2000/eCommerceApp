//
//  RefundReqVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 2/11/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class RefundReqVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    struct Invoices: Decodable {
        let inv_number: String?
        
        init?(json: JSON) {
            self.inv_number = "inv_number" <~~ json
        }
    }
    
    struct InvoiceResult: Decodable {
        let status: String?
        let invoice: [Invoices]?
        
        init?(json: JSON) {
            self.status = "Status" <~~ json
            self.invoice = "invoices" <~~ json
        }
    }
    
    struct RefundStatus: Decodable {
        let status: String?
        let message: String?
        
        init?(json: JSON) {
            self.status = "Status" <~~ json
            self.message = "message" <~~ json
        }
    }
    
    @IBOutlet weak var invoiceNumber: UITextField!
    @IBOutlet weak var itemsRefund: UITextField!
    @IBOutlet weak var ItemsDetail: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    
    let userdefault = UserDefaults.standard
    let invoicePicker = UIPickerView()
    var invoiceData = [String]()
    let itemsPicker = UIPickerView()
    var itemsData = ["All items", "Certain items"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.topItem!.title = "Back"
        self.title = "Request For Refund"
        
        ItemsDetail.isHidden = true
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RefundReqVC.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RefundReqVC.dismissKeyboard))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        invoiceNumber.inputAccessoryView = toolBar
        itemsRefund.inputAccessoryView = toolBar
        
        if ((userdefault.object(forKey: "loginStatus") as? Bool != nil) && (userdefault.object(forKey: "userid") as? String != nil)) {
            if (userdefault.object(forKey: "loginStatus") as? Bool != false) {
                invoiceNumber.tag = 0
                invoicePicker.tag = 0
                invoicePicker.delegate = self
                invoicePicker.dataSource = self
                invoiceNumber.inputView = invoicePicker
                itemsRefund.tag = 1
                itemsPicker.tag = 1
                itemsPicker.delegate = self
                itemsPicker.dataSource = self
                itemsRefund.inputView = itemsPicker
            }
        } else {
            let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Please log in to access this page.", preferredStyle: UIAlertControllerStyle.alert)
            alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  {(action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertStatus, animated: true, completion: nil)
        }
        
        Alamofire.request("").validate(contentType: ["application/json"]).responseJSON{ response in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if invoiceData.isEmpty == true {
            get_data_from_url(url: BaseURL.rootURL()+"getInvoices_forRefund.php")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func get_data_from_url(url:String){
        if invoiceData.isEmpty == false {
            self.invoiceData.removeAll(keepingCapacity: false)
        }
        
        let parameterURL = ["userid":self.userdefault.object(forKey: "userid") as! String]
        Alamofire.request(url, parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
            switch response.result{
            case .success(let data):
                guard let value = data as? JSON,
                    let eventsArrayJSON = value["Invoice"] as? [JSON]
                    else { fatalError() }
                let invoiceresult = [InvoiceResult].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((invoiceresult?.count)!){
                    for k in 0 ..< Int((invoiceresult?[j].invoice?.count)!) {
                        self.invoiceData.append((invoiceresult?[j].invoice?[k].inv_number!)!)
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.viewDidLoad()
                })
                break
            case .failure(let error):
                print("Error: \(error)")
                break
            }
        }
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        let items: String
        if self.itemsRefund.text! == "All items" {
            items = self.itemsRefund.text!
        } else {
            items = self.ItemsDetail.text!
        }
        let parameterURL = ["userid":self.userdefault.object(forKey: "userid") as! String, "inv_number":self.invoiceNumber.text!,"items":items]
        Alamofire.request(BaseURL.rootURL()+"refundReq.php", parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
            switch response.result{
            case .success(let data):
                guard let value = data as? JSON,
                    let eventsArrayJSON = value["RefundRequest"] as? [JSON]
                    else { fatalError() }
                let refundstatus = [RefundStatus].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((refundstatus?.count)!){
                    let alertStatus = UIAlertController (title: "Refund Request \((refundstatus?[j].status!)!)", message: "\((refundstatus?[j].message!)!)", preferredStyle: UIAlertControllerStyle.alert)
                    alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  nil))
                    self.present(alertStatus, animated: true, completion: nil)
                }
                break
            case .failure(let error):
                print("Error: \(error)")
                break
            }
        }
        /*let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Submit button pressed.", preferredStyle: UIAlertControllerStyle.alert)
        alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  nil))
        self.present(alertStatus, animated: true, completion: nil)*/
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var a = 0
        if pickerView.tag == 0 {
            a = invoiceData.count
        } else if pickerView.tag == 1 {
            a = itemsData.count
        }
        
        return a
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var a = ""
        if pickerView.tag == 0 {
            a = invoiceData[row]
        } else if pickerView.tag == 1 {
            a = itemsData[row]
        }
        
        return a
    }
    
    /*func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     if pickerView.tag == 0 {
     invoiceNumber.text = invoiceData[row]
     } else if pickerView.tag == 1 {
     itemsRefund.text = itemsData[row]
     }
     }*/
    
    func donePicker()
    {
        if (invoiceNumber.isEditing) {
            let row = invoicePicker.selectedRow(inComponent: 0)
            invoiceNumber.text = pickerView(invoicePicker, titleForRow: row, forComponent: 0)
        } else if (itemsRefund.isEditing) {
            let row = itemsPicker.selectedRow(inComponent: 0)
            itemsRefund.text = pickerView(itemsPicker, titleForRow: row, forComponent: 0)
        }
        
        if itemsRefund.text! == "Certain items" {
            ItemsDetail.isHidden = false
        } else {
            ItemsDetail.isHidden = true
        }
        
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            invoicePicker.isHidden = false
        } else if textField.tag == 1 {
            itemsPicker.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            invoicePicker.isHidden = true
        } else if textField.tag == 1 {
            itemsPicker.isHidden = true
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
    
    //ngehilangin keyboard kalo user tap di luar field #2
    func dismissKeyboard() {
        view.endEditing(true)
    }

}
