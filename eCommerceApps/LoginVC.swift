//
//  LoginVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/27/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imv_logo: UIImageView!
    @IBOutlet weak var text_email: UITextField!
    @IBOutlet weak var text_password: UITextField!
    @IBOutlet weak var btn_login: UIButton!
    @IBOutlet weak var btn_forgetpass: UIButton!
    @IBOutlet weak var btn_signup: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    
    let userdefault = UserDefaults.standard
    
    struct LoginStatus: Decodable{
        let status: String?
        let message: String?
        let userid: String?
        let usercurency: String?
        
        init?(json: JSON){
            self.status = "status" <~~ json
            self.message = "message" <~~ json
            self.userid = "userid" <~~ json
            self.usercurency = "usercurrency" <~~ json
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        text_email.delegate = self
        text_password.delegate = self
        
        btn_login.layer.cornerRadius = 5
        btn_forgetpass.layer.cornerRadius = 5
        btn_signup.layer.cornerRadius = 5
        btn_cancel.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Log In Form"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //ngehilangin keyboard kalo user tap di luar field #1
        let tapAnywhere: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(LoginVC.dismissKeyboard))
        view.addGestureRecognizer(tapAnywhere)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isValidEmail(email:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidPass(pass:String) -> Bool {
        let passRegEx = "[A-Z0-9a-z_!@#$%&*]{6,}"
        
        let passTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passTest.evaluate(with: pass)
    }
    
    //akun untuk coba login
    //email: luthfir272@gmail.com
    //password: 123asd&
    @IBAction func loginButton(_ sender: UIButton) {
        if ((self.text_password.text?.isEmpty)! && (self.text_email.text?.isEmpty)!) {
            let alertEmpty = UIAlertController (title: "Warning", message: "All fields must be filled.", preferredStyle: UIAlertControllerStyle.alert)
            alertEmpty.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertEmpty, animated: true, completion: nil)
        } else {
            if (isValidEmail(email: self.text_email.text!)) {
                if (isValidPass(pass: self.text_password.text!)) {
                    let parameterURL = ["email":"\(self.text_email.text!)", "password":"\(self.text_password.text!)"]
                    Alamofire.request("https://imperio.co.id/project/ecommerceApp/login.php", parameters: parameterURL).validate(contentType: ["application/json"]).responseJSON{ response in
                        switch response.result{
                        case .success(let data):
                            guard let value = data as? JSON,
                                let eventsArrayJSON = value["loginstatus"] as? [JSON]
                                else { fatalError() }
                            let loginstatus = [LoginStatus].from(jsonArray: eventsArrayJSON)
                            if (loginstatus?[0].status)! == "failed" {
                                let alert = UIAlertController (title: "Login Error", message: (loginstatus?[0].message)!, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            } else if (loginstatus?[0].status)! == "success" {
                                self.userdefault.set((loginstatus?[0].userid)!, forKey: "userid")
                                self.userdefault.set(true, forKey: "loginStatus")
                                self.userdefault.set((loginstatus?[0].usercurency)!, forKey: "user_currency")
                                self.userdefault.synchronize()
                                print("user currency at login: \(self.userdefault.object(forKey: "user_currency") as! String)")
                                self.performSegue(withIdentifier: "SegueFromLoginToMoreView", sender: self)
                            }
                        case .failure(let error):
                            print("Error request data from server: \(error)")
                            break
                        }
                    }
                } else {
                    let alertPass = UIAlertController (title: "Invalid Password", message: "Your password must contains alphabets, special characters and numbers and minimum length is 6.", preferredStyle: UIAlertControllerStyle.alert)
                    alertPass.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: { (action) in
                        self.text_password.isSelected = true
                    }))
                    self.present(alertPass, animated: true, completion: nil)
                }
            } else {
                let alertEmail = UIAlertController (title: "Invalid Email", message: "Your email format is wrong.", preferredStyle: UIAlertControllerStyle.alert)
                alertEmail.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: { (action) in
                    self.text_email.isSelected = true
                }))
                self.present(alertEmail, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        performSegue(withIdentifier: "SegueToSignUpFromLogin", sender: self)
    }
    
    
    @IBAction func forgetpassButton(_ sender: UIButton) {
        performSegue(withIdentifier: "SegueToForgetPassFromLogin", sender: self)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        if (!((self.text_password.text?.isEmpty)!) && !((self.text_email.text?.isEmpty)!)) {
            self.text_password.text = nil
            self.text_email.text = nil
        }
        performSegue(withIdentifier: "SegueFromLoginToMoreView", sender: self)
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
    
    /*func textFieldShouldClear(_ textField: UITextField) -> Bool {
     textField.clearButtonMode = UITextFieldViewMode.whileEditing
     return true;
     }*/
    
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
