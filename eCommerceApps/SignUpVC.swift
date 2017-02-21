//
//  SignUpVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/29/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire

class SignUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imv_logo: UIImageView!
    @IBOutlet weak var text_email: UITextField!
    @IBOutlet weak var text_password: UITextField!
    @IBOutlet weak var text_password_verif: UITextField!
    @IBOutlet weak var btn_signup: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    
    let userdefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        text_email.delegate = self
        text_password.delegate = self
        text_password_verif.delegate = self
        btn_signup.layer.cornerRadius = 5
        btn_cancel.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Sign Up Form"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //ngehilangin keyboard kalo user tap di luar field #1
        let tapAnywhere: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(SignUpVC.dismissKeyboard))
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
    
    @IBAction func btn_signup(_ sender: UIButton) {
        if ((self.text_password.text?.isEmpty)! && (self.text_email.text?.isEmpty)! && (self.text_password_verif.text?.isEmpty)!) {
            let alertEmpty = UIAlertController (title: "Warning", message: "All fields must be filled.", preferredStyle: UIAlertControllerStyle.alert)
            alertEmpty.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertEmpty, animated: true, completion: nil)
        } else {
            if ((self.text_password.text! == self.text_password_verif.text!)) {
                if (isValidEmail(email: self.text_email.text!)) {
                    if (isValidPass(pass: self.text_password.text!)) {
                        let parameterURL = ["email":"\(self.text_email.text!)", "password":"\(self.text_password.text!)"]
                        Alamofire.request(BaseURL.rootURL()+"registration.php", parameters: parameterURL).validate(contentType: ["text/html"]).responseString{ response in
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
                                print("Server response message: \(data)")
                                switch data {
                                case "Please Fill All Values.", "Your account is already exist. Please go to login page.", "Please try again.":
                                    let alertReg = UIAlertController (title: "Registration Error", message: data, preferredStyle: UIAlertControllerStyle.alert)
                                    alertReg.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: nil))
                                    self.present(alertReg, animated: true, completion: nil)
                                default:
                                    self.userdefault.set(data, forKey: "userid")
                                    self.userdefault.set(true, forKey: "loginStatus")
                                    self.performSegue(withIdentifier: "SegueToUpdateProfFromSignUp", sender: self)
                                }
                            case .failure(let error):
                                //self.dismiss(animated: false, completion: nil)
                                print("Error request data from server: \(error)")
                                let alert1 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                                self.present(alert1, animated: true, completion: nil)
                                break
                            }
                        }
                    } else {
                        let alertPass = UIAlertController (title: "Invalid Password", message: "Your password must contains alphabets, special characters and numbers and minimum length is 6.", preferredStyle: UIAlertControllerStyle.alert)
                        alertPass.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertPass, animated: true, completion: nil)
                        self.text_password.isSelected = true
                    }
                } else {
                    let alertEmail = UIAlertController (title: "Invalid Email", message: "Your email format is wrong.", preferredStyle: UIAlertControllerStyle.alert)
                    alertEmail.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertEmail, animated: true, completion: nil)
                    self.text_email.isSelected = true
                }
            } else {
                let alertVerif = UIAlertController (title: "Wrong Password", message: "Your first password is not match with the second password.", preferredStyle: UIAlertControllerStyle.alert)
                alertVerif.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertVerif, animated: true, completion: nil)
                self.text_password_verif.isSelected = true
            }
        }
    }
    
    @IBAction func btn_cancel(_ sender: UIButton) {
        if (!((self.text_password.text?.isEmpty)!) && !((self.text_email.text?.isEmpty)!) && !((self.text_password_verif.text?.isEmpty)!)) {
            self.text_password.text = nil
            self.text_email.text = nil
            self.text_password_verif.text = nil
        }
        performSegue(withIdentifier: "SegueFromSignUpToLogin", sender: self)
    }
    
    //ngehilangin keyboard kalo user tap di luar field #2
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToUpdateProfFromSignUp"{
            let DestVc = segue.destination as! UserProfileVC
            DestVc.VCOrigin = "SignUpVC"
        }
    }
    
    /*func textFieldShouldClear(_ textField: UITextField) -> Bool {
     textField.clearButtonMode = UITextFieldViewMode.whileEditing
     return true
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
