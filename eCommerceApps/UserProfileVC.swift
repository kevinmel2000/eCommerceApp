//
//  UpdateProfileViewController.swift
//  eCommerce
//
//  Created by Luthfi Fathur Rahman on 10/24/16.
//  Copyright © 2016 Imperio Teknologi Indonesia. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class UserProfileVC: UIViewController, UITextFieldDelegate {
    
    var VCOrigin: String!
    
    @IBOutlet weak var user_name: UITextField!
    @IBOutlet weak var user_street: UITextField!
    @IBOutlet weak var user_city: UITextField!
    @IBOutlet weak var user_province: UITextField!
    @IBOutlet weak var user_country: UITextField!
    @IBOutlet weak var user_postalCode: UITextField!
    @IBOutlet weak var user_mobileNumber: UITextField!
    @IBOutlet weak var btn_submit: UIButton!
    
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
    
    let userdefault = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "User Info"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_submit.layer.cornerRadius = 5
        
        if ((userdefault.object(forKey: "loginStatus") as? Bool != nil) && (userdefault.object(forKey: "userid") as? String != nil)) {
            if (userdefault.object(forKey: "loginStatus") as? Bool != false) {
                user_name.delegate = self
                user_street.delegate = self
                user_city.delegate = self
                user_province.delegate = self
                user_postalCode.delegate = self
                user_country.delegate = self
                
                get_data_from_url(url: "https://imperio.co.id/project/ecommerceApp/userprofile.php")
            }
        } else {
            let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Please log in to access this page.", preferredStyle: UIAlertControllerStyle.alert)
            alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  {(action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertStatus, animated: true, completion: nil)
        }
        
        //ngehilangin keyboard kalo user tap di luar field #1
        let tapAnywhere: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(UserProfileVC.dismissKeyboard))
        view.addGestureRecognizer(tapAnywhere)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn_submit(_ sender: UIButton) {
        if ((user_name.text?.isEmpty)! && (user_street.text?.isEmpty)! && (user_city.text?.isEmpty)! && (user_province.text?.isEmpty)! && (user_country.text?.isEmpty)! && (user_postalCode.text?.isEmpty)! && (user_mobileNumber.text?.isEmpty)!) {
            let alert = UIAlertController (title: "Warning", message: "All Fields must be filled.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default,handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let parameterURL = ["name":user_name.text!, "street":user_street.text!, "city":user_city.text!, "province":user_province.text!, "country":user_country.text!, "postalCode":user_postalCode.text!, "mobileNumber":user_mobileNumber.text!]
            Alamofire.request("https://imperio.co.id/project/ecommerceApp/updateUserProfile.php", parameters: parameterURL).validate(contentType: ["text/html"]).responseString{ response in
                /*let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
                alert.view.tintColor = UIColor.black
                let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(frame: CGRect(x: (self.view.frame.size.width/2),y: (self.view.frame.size.height)/2,width: (self.view.frame.size.width)*0.4,height: (self.view.frame.size.height)*0.4))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                loadingIndicator.startAnimating();
                
                alert.view.addSubview(loadingIndicator)
                self.present(alert, animated: true, completion: nil)*/
                
                switch response.result{
                case .success(let data):
                    //self.dismiss(animated: false, completion: nil)
                    if data == "User profile data input success." {
                        let alertStatus = UIAlertController (title: "eCommerce App Message", message: data, preferredStyle: UIAlertControllerStyle.alert)
                        alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  {(action) in
                            switch  self.VCOrigin {
                            case "SegueToUpdateProfFromUserProf":
                                self.navigationController?.popViewController(animated: true)
                            case "SegueToUpdateProfFromSignUp":
                                self.performSegue(withIdentifier: "SegueFromUpdateProfToMoreView", sender: self)
                            default:
                                break
                            }
                        }))
                        self.present(alertStatus, animated: true, completion: nil)
                    }
                    break
                case .failure(let error):
                    //self.dismiss(animated: false, completion: nil)
                    print("Error: \(error)")
                    let alert1 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert1, animated: true, completion: nil)
                    break
                }
            }
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
                        self.user_name.text = (Userprofile?[j].UserName!)!
                        self.user_street.text = (Userprofile?[j].UserAddr_street!)!
                        self.user_city.text = (Userprofile?[j].UserAddr_city!)!
                        self.user_province.text = (Userprofile?[j].UserAddr_province!)!
                        self.user_country.text = (Userprofile?[j].UserAddr_country!)!
                        self.user_postalCode.text = (Userprofile?[j].UserAddr_postalCode!)!
                        self.user_mobileNumber.text = (Userprofile?[j].UserMobilePh!)!
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    //ngehilangin keyboard kalo user tap di luar field #2
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
