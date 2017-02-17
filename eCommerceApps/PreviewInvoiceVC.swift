//
//  PreviewInvoiceVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 2/7/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import MessageUI
import Alamofire
import Gloss


class PreviewInvoiceVC: UIViewController {
    
    @IBOutlet weak var webPreview: UIWebView!
    
    //var invoiceInfo = [String: AnyObject]()
    var items = [[String:String]]()
    var subs = [Int]()
    var invoiceComposer: InvoiceComposer!
    var HTMLContent: String!
    var invoiceNumber: String!
    var invoiceDate: String!
    var totalAmount: String!
    var userInfo: String!
    
    let userdefault = UserDefaults.standard
    
    //struct yang dipakai dari Gloss
    struct UserProfile: Decodable{
        let UserID: Int?
        let UserPhoto: String?
        let UserName: String?
        let UserAddr_street: String?
        let UserAddr_city: String?
        let UserAddr_province: String?
        let UserAddr_country: String?
        let UserAddr_postalCode: String?
        let UserMobilePh: String?
        let UserEmail: String?
        
        init?(json: JSON){
            self.UserID = "id" <~~ json
            self.UserPhoto = "photo" <~~ json
            self.UserName = "name" <~~ json
            self.UserAddr_street = "street" <~~ json
            self.UserAddr_city = "city" <~~ json
            self.UserAddr_province = "province" <~~ json
            self.UserAddr_country = "country" <~~ json
            self.UserAddr_postalCode = "postalcode" <~~ json
            self.UserMobilePh = "mobilephone" <~~ json
            self.UserEmail = "email" <~~ json
        }
    }
    
    struct Products: Decodable {
        let status: String?
        let prod_id: String?
        let prod_qty: String?
        let prod_price: String?
        let prod_name: String?
        
        init?(json: JSON) {
            self.status = "Status" <~~ json
            self.prod_id = "inv_prodID" <~~ json
            self.prod_qty = "inv_prodQty" <~~ json
            self.prod_price = "prod_price" <~~ json
            self.prod_name = "prod_name" <~~ json
        }
    }
    
    struct ProductResult: Decodable {
        let status: String?
        let total: String?
        let products: [Products]?
        
        init?(json: JSON) {
            self.status = "Status" <~~ json
            self.total = "Total" <~~ json
            self.products = "Products" <~~ json
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.topItem!.title = "Back"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("Invoice Number: \(invoiceNumber!)")
        //print("Invoice Date: \(invoiceDate!)")
        //items.append(["item": "product 1", "price": "10000"])
        
        get_data_from_url(url: BaseURL.rootURL()+"userprofile.php")
        get_product_data(url: BaseURL.rootURL()+"getInvoiceData_forPreview.php")
        
        //totalAmount = "0.0"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: IBAction Methods
    
    
    /*@IBAction func exportToPDF(_ sender: AnyObject) {
        invoiceComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent)
        showOptionsAlert()
    }*/
    
    
    // MARK: Custom Methods
    
    func createInvoiceAsHTML() {
        invoiceComposer = InvoiceComposer()
        if let invoiceHTML = invoiceComposer.renderInvoice(invoiceNumber: invoiceNumber!,
                                                           invoiceDate: invoiceDate!,
                                                           recipientInfo: userInfo,
                                                           items: items,
                                                           totalAmount: totalAmount) {
            
            webPreview.loadHTMLString(invoiceHTML, baseURL: NSURL(string: invoiceComposer.pathToInvoiceHTMLTemplate!)! as URL)
            HTMLContent = invoiceHTML
        }
    }
    
    
    
    func showOptionsAlert() {
        let alertController = UIAlertController(title: "Success", message: "Your invoice has been successfully printed to a PDF file.\n\nWhat do you want to do now?", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionPreview = UIAlertAction(title: "Preview it", style: UIAlertActionStyle.default) { (action) in
            if let filename = self.invoiceComposer.pdfFilename, let url = URL(string: filename) {
                let request = URLRequest(url: url)
                self.webPreview.loadRequest(request)
            }
        }
        
        let actionEmail = UIAlertAction(title: "Send by Email", style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
                self.sendEmail()
            }
        }
        
        let actionNothing = UIAlertAction(title: "Nothing", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        alertController.addAction(actionPreview)
        alertController.addAction(actionEmail)
        alertController.addAction(actionNothing)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.setSubject("Invoice")
            mailComposeViewController.addAttachmentData(NSData(contentsOfFile: invoiceComposer.pdfFilename)! as Data, mimeType: "application/pdf", fileName: "Invoice")
            present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func get_data_from_url(url:String){
        let parameterURL = ["userid":self.userdefault.object(forKey: "userid") as! String]
        Alamofire.request(url, parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
            
            switch response.result{
            case .success(let data):
                guard let value = data as? JSON,
                    let eventsArrayJSON = value["userprof"] as? [JSON]
                    else { fatalError() }
                let Userprofile = [UserProfile].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((Userprofile?.count)!) {
                    if (Userprofile?[j].UserName! != "None") {
                        
                        self.userInfo = "\((Userprofile?[j].UserName!)!), \((Userprofile?[j].UserAddr_street!)!), \((Userprofile?[j].UserAddr_city!)!), \((Userprofile?[j].UserAddr_province!)!), \((Userprofile?[j].UserAddr_country!)!). \((Userprofile?[j].UserAddr_postalCode!)!)"
                        print("User Info = \(self.userInfo)")
                    }
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
    
    func get_product_data(url:String){
        items.removeAll(keepingCapacity: false)
        let parameterURL = ["inv_number": self.invoiceNumber!]
        Alamofire.request(url, parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
            
            switch response.result{
            case .success(let data):
                guard let value = data as? JSON,
                    let eventsArrayJSON = value["Invoice"] as? [JSON]
                    else { fatalError() }
                let productresult = [ProductResult].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((productresult?.count)!) {
                    if ((productresult?[j].status)! == "Success") {
                        for k in 0 ..< Int((productresult?[j].products?.count)!) {
                            self.items.append(["item": (productresult?[j].products?[k].prod_name)!, "price": (productresult?[j].products?[k].prod_price)!, "qty": (productresult?[j].products?[k].prod_qty)!])
                        }
                        /*for item in self.items {
                            print("Isi items: \(item)")
                        }*/
                        self.totalAmount = (productresult?[j].total)!
                        self.createInvoiceAsHTML()
                    } else {
                        let alert1 = UIAlertController (title: "Error", message: "Sorry, please try again.", preferredStyle: UIAlertControllerStyle.alert)
                        alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alert1, animated: true, completion: nil)
                    }
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
