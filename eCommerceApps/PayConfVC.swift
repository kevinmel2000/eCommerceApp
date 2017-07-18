//
//  PayConfVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 2/11/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class PayConfVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBOutlet weak var invoiceNumber: UITextField!
    @IBOutlet weak var transferTo: UITextField!
    @IBOutlet weak var senderBank: UITextField!
    @IBOutlet weak var senderAccNumber: UITextField!
    @IBOutlet weak var transferAmount: UITextField!
    @IBOutlet weak var btnTransferRec: UIButton!
    @IBOutlet weak var imageTransferRec: UIImageView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    struct SubmissionResult: Decodable {
        let status: String?
        let message: String?
        
        init?(json: JSON) {
            self.status = "Status" <~~ json
            self.message = "message" <~~ json
        }
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
    
    struct BankInfo: Decodable{
        let bank: String?
        
        init?(json: JSON) {
            self.bank = "bank" <~~ json
        }
    }
    
    let userdefault = UserDefaults.standard
    
    let MerchantBankPicker = UIPickerView()
    var MerchantBanks = [String]()
    let invoicePicker = UIPickerView()
    var invoiceData = [String]()
    var dataGambar: Data!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.topItem!.title = "Back"
        self.title = "Payment Confirmation"
        
        btnTransferRec.layer.cornerRadius = 5
        invoiceNumber.tag = 0
        invoiceNumber.delegate = self
        invoicePicker.tag = 0
        invoicePicker.delegate = self
        invoicePicker.dataSource = self
        transferTo.tag = 1
        transferTo.delegate = self
        MerchantBankPicker.tag = 1
        MerchantBankPicker.delegate = self
        MerchantBankPicker.dataSource = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PayConfVC.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PayConfVC.cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        invoiceNumber.inputAccessoryView = toolBar
        transferTo.inputAccessoryView = toolBar
        
        if ((userdefault.object(forKey: "loginStatus") as? Bool != nil) && (userdefault.object(forKey: "userid") as? String != nil)) {
            if (userdefault.object(forKey: "loginStatus") as? Bool != false) {
                transferTo.inputView = MerchantBankPicker
                invoiceNumber.inputView = invoicePicker
            }
        } else {
            let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Please log in to access this page.", preferredStyle: UIAlertControllerStyle.alert)
            alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  {(action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertStatus, animated: true, completion: nil)
        }
        
        let tapAnywhere: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(PayConfVC.dismissKeyboard))
        view.addGestureRecognizer(tapAnywhere)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if invoiceData.isEmpty == true {
            get_data_from_url(url: BaseURL.rootURL()+"getInvoices_forConfirmation.php")
        }
        get_bankData(url: BaseURL.rootURL()+"shop_bankInfo.php")
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
    
    func get_bankData(url:String){
        if MerchantBanks.isEmpty == false {
            self.MerchantBanks.removeAll(keepingCapacity: false)
        }
        
        Alamofire.request(url).validate(contentType: ["application/json"]).responseJSON{ response in
            switch response.result{
            case .success(let data):
                guard let value = data as? JSON,
                    let eventsArrayJSON = value["bankInfo"] as? [JSON]
                    else { fatalError() }
                let bankinfo = [BankInfo].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((bankinfo?.count)!){
                    self.MerchantBanks.append((bankinfo?[j].bank)!)
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
    
    func donePicker()
    {
        if (invoiceNumber.isEditing) {
            let row = invoicePicker.selectedRow(inComponent: 0)
            invoiceNumber.text = pickerView(invoicePicker, titleForRow: row, forComponent: 0)
        } else if (transferTo.isEditing) {
            let row = MerchantBankPicker.selectedRow(inComponent: 0)
            transferTo.text = pickerView(MerchantBankPicker, titleForRow: row, forComponent: 0)
        }
        
        self.view.endEditing(true)
    }
    
    func cancelPicker(){
        self.view.endEditing(true)
    }
    
    @IBAction func btnTransferRec(_ sender: UIButton) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        myPickerController.allowsEditing = true
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        if(((invoiceNumber.text?.isEmpty)!) || ((transferTo.text?.isEmpty)!) || ((senderBank.text?.isEmpty)!) || ((senderAccNumber.text?.isEmpty)!) || ((transferAmount.text?.isEmpty)!) || (imageTransferRec.image == nil)) {
            let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Please fill all fields.", preferredStyle: UIAlertControllerStyle.alert)
            alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  nil))
            self.present(alertStatus, animated: true, completion: nil)
        } else {
            let parameterURL = ["userId":self.userdefault.object(forKey: "userid") as! String, "invoice":self.invoiceNumber.text!, "transferto":self.transferTo.text!,  "senderbank":self.senderBank.text!, "senderaccnum":self.senderAccNumber.text!, "transferamount":self.transferAmount.text!]
            print(parameterURL)
            Alamofire.request(BaseURL.rootURL()+"paymentConfirmation.php", parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
                switch response.result{
                case .success(let data):
                    guard let value = data as? JSON,
                        let eventsArrayJSON = value["PaymentConfirmation"] as? [JSON]
                        else { fatalError() }
                    let submissionresult = [SubmissionResult].from(jsonArray: eventsArrayJSON)
                    for j in 0 ..< Int((submissionresult?.count)!){
                        let alertStatus = UIAlertController (title: "Payment Confirmation \((submissionresult?[j].status!)!)", message: (submissionresult?[j].message!)!, preferredStyle: UIAlertControllerStyle.alert)
                        alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: {(action) in
                            if ((submissionresult?[j].status!)! == "Success") {
                                //print(self.dataGambar)
                                self.myImageUploadRequest(imageData: self.dataGambar)
                            }
                            
                        }))
                        self.present(alertStatus, animated: true, completion: nil)
                        
                    }
                    break
                case .failure(let error):
                    print("Error: \(error)")
                    break
                }
            }
        }
    }
    
    func myImageUploadRequest(imageData: Data) {
        let myUrl = NSURL(string: BaseURL.rootURL()+"uploadReceipt.php")
        let request = NSMutableURLRequest(url:myUrl! as URL)
        request.httpMethod = "POST"
        let param = ["userId":self.userdefault.object(forKey: "userid") as! String, "invoice": self.invoiceNumber.text!]
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData as NSData, boundary: boundary) as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            // print out response object
            print("******* response = \(response!)")
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            DispatchQueue.main.async(execute: {
                self.viewWillAppear(true)
            })
            //self.viewDidLoad()
        }
        
        task.resume()
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "\(invoiceNumber.text!.replacingOccurrences(of: "/", with: "_")).jpg"//"user-profile.jpg"
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { //UIImagePickerControllerOriginalImage
            print("There is an errorr to get image info.")
            return
        }
        print("Info debug desc: \(info.debugDescription)")
        let compressionQuality: CGFloat = 0.5
        guard let imageData = UIImageJPEGRepresentation(image, compressionQuality) else {
            print("Unable to get JPEG representation for image \(image)")
            return
        }
        
        self.dataGambar = imageData
        self.dismiss(animated: true, completion: nil)
        //myImageUploadRequest(imageData: imageData)
        self.imageTransferRec.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var a = 0
        if pickerView.tag == 0 {
            a = invoiceData.count
        } else if pickerView.tag == 1 {
            a = MerchantBanks.count
        }
        
        return a
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var a = ""
        if pickerView.tag == 0 {
            a = invoiceData[row]
        } else if pickerView.tag == 1 {
            a = MerchantBanks[row]
        }
        
        return a
    }
    
    /*func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     if pickerView.tag == 0 {
     invoiceNumber.text = invoiceData[row]
     } else if pickerView.tag == 1 {
     transferTo.text = MerchantBanks[row]
     }
     }*/
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            invoicePicker.isHidden = false
            invoicePicker.selectRow(invoicePicker.selectedRow(inComponent: 0), inComponent: 0, animated: true)
        } else if textField.tag == 1 {
            MerchantBankPicker.isHidden = false
            MerchantBankPicker.selectRow(MerchantBankPicker.selectedRow(inComponent: 0), inComponent: 0, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            invoicePicker.isHidden = true
        } else if textField.tag == 1 {
            MerchantBankPicker.isHidden = true
        }
    }
    
    //ngehilangin keyboard kalo user tap di luar field #2
    func dismissKeyboard() {
        view.endEditing(true)
    }

}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
