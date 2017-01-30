//
//  ForgetPassVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/27/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire

class ForgetPassVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imv_logo: UIImageView!
    @IBOutlet weak var text_email: UITextField!
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Forget Password"
        btn_submit.layer.cornerRadius = 5
        btn_cancel.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //ngehilangin keyboard kalo user tap di luar field #1
        let tapAnywhere: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ForgetPassVC.dismissKeyboard))
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
    
    @IBAction func btn_submit(_ sender: UIButton) {
        if (!((self.text_email.text?.isEmpty)!)) {
            if (isValidEmail(email: self.text_email.text!)) {
                let parameterURL = ["email":"\(self.text_email.text!)"]
                Alamofire.request("https://imperio.co.id/project/ecommerceApp/forgotpass.php", parameters: parameterURL).validate(contentType: ["text/html"]).responseString{ response in
                    //print(response.result.value)
                    switch response.result{
                    case .success(let data):
                        print("Server response message: \(data)")
                        switch data {
                        case "Mail failed to sent. Please try again.", "Upss something went wrong.":
                            let alertReg = UIAlertController (title: "Reset Password Error", message: data, preferredStyle: UIAlertControllerStyle.alert)
                            alertReg.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertReg, animated: true, completion: nil)
                        case "Your password has been reset.":
                            let alertReg2 = UIAlertController (title: "Reset Password Success", message: data, preferredStyle: UIAlertControllerStyle.alert)
                            alertReg2.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertReg2, animated: true, completion: nil)
                            self.performSegue(withIdentifier: "SegueFromForgetPassToLogin", sender: self)
                        default:
                            break
                        }
                    case .failure(let error):
                        print("Error request data from server: \(error)")
                        let alert1 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alert1, animated: true, completion: nil)
                        break
                    }
                }
                
            } else {
                let alertEmail = UIAlertController (title: "Invalid Email", message: "Your email format is wrong.", preferredStyle: UIAlertControllerStyle.alert)
                alertEmail.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertEmail, animated: true, completion: nil)
            }
        } else {
            let alertEmpty = UIAlertController (title: "Warning", message: "All fields must be filled.", preferredStyle: UIAlertControllerStyle.alert)
            alertEmpty.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertEmpty, animated: true, completion: nil)
        }
    }
    
    @IBAction func btn_cancel(_ sender: UIButton) {
        if (!((self.text_email.text?.isEmpty)!)) {
            self.text_email.text = nil
        }
        performSegue(withIdentifier: "SegueFromForgetPassToLogin", sender: self)
    }
    
    //ngehilangin keyboard kalo user tap di luar field #2
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.clearsOnBeginEditing = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
    }
    
    
    /*func textFieldShouldClear(_ textField: UITextField) -> Bool {
     textField.clearButtonMode = UITextFieldViewMode.whileEditing
     return true
     }*/

}
