//
//  ChangePassVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/29/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire

class ChangePassVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var text_oldPass: UITextField!
    @IBOutlet weak var text_newPass: UITextField!
    @IBOutlet weak var btn_submit: UIButton!
    
    let userdefault = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Change Password Form"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_submit.layer.cornerRadius = 5
        
        if ((userdefault.object(forKey: "loginStatus") as? Bool != nil) && (userdefault.object(forKey: "userid") as? String != nil)) {
            if (userdefault.object(forKey: "loginStatus") as? Bool != false) {
                text_newPass.delegate = self
                text_oldPass.delegate = self
            }
        } else {
            let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Please log in to access this page.", preferredStyle: UIAlertControllerStyle.alert)
            alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  {(action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertStatus, animated: true, completion: nil)
        }
        
        //ngehilangin keyboard kalo user tap di luar field #1
        let tapAnywhere: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ChangePassVC.dismissKeyboard))
        view.addGestureRecognizer(tapAnywhere)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //ngehilangin keyboard kalo user tap di luar field #2
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func isValidPass(pass:String) -> Bool {
        let passRegEx = "[A-Z0-9a-z_!@#$%&*]{6,}"
        
        let passTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passTest.evaluate(with: pass)
    }
    
    @IBAction func btn_submit(_ sender: UIButton) {
        if ((self.text_oldPass.text?.isEmpty)! || (self.text_newPass.text?.isEmpty)!) {
            let alertField = UIAlertController (title: "Warning", message: "All fields must be filled.", preferredStyle: UIAlertControllerStyle.alert)
            alertField.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertField, animated: true, completion: nil)
        } else {
            if (isValidPass(pass: self.text_newPass.text!)){
                let alertMakeSure = UIAlertController (title: "Change Password", message: "Are you sure to change your password?", preferredStyle: UIAlertControllerStyle.alert)
                alertMakeSure.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default,handler: { (action) in
                    let parameterURL = ["userid":self.userdefault.object(forKey: "userid") as! String, "old_password":self.text_oldPass.text! as String,"new_password":self.text_newPass.text! as String]
                    Alamofire.request("https://imperio.co.id/project/ecommerceApp/changepass.php", parameters: parameterURL).validate(contentType: ["text/html"]).responseString{ response in
                        //print(response.result.value)
                        switch response.result{
                        case .success(let data):
                            switch data {
                            case "Your password has been changed. Please log-in again using your new password.":
                                let alertSuccess = UIAlertController (title: "Change Password Success", message: data, preferredStyle: UIAlertControllerStyle.alert)
                                alertSuccess.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: { (action) in
                                    self.userdefault.set(false, forKey: "loginStatus")
                                    self.userdefault.removeObject(forKey: "userid")
                                    self.userdefault.synchronize()
                                    self.performSegue(withIdentifier: "SegueToLoginFromChangePass", sender: self)
                                }))
                                self.present(alertSuccess, animated: true, completion: nil)
                            case "Upss something went wrong.", "Wrong password.", "Your data is not found.":
                                let alertError = UIAlertController (title: "Change Password Error", message: data, preferredStyle: UIAlertControllerStyle.alert)
                                alertError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                                self.present(alertError, animated: true, completion: nil)
                            default:
                                break
                            }
                            break
                        case .failure(let error):
                            print("Error: \(error)")
                            break
                        }
                    }
                }))
                alertMakeSure.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertMakeSure, animated: true, completion: nil)
            } else {
                let alertPass = UIAlertController (title: "Invalid Password", message: "Your password must contains alphabets, special characters and numbers and minimum length is 6.", preferredStyle: UIAlertControllerStyle.alert)
                alertPass.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: { (action) in
                    self.text_newPass.isSelected = true
                }))
                self.present(alertPass, animated: true, completion: nil)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        
        return false
    }

}
