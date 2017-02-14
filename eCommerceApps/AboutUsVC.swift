//
//  AboutUsVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/29/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

//the dummy: http://www.drxlr.com/about/

class AboutUsVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var btn_refresh: UIBarButtonItem!
    @IBOutlet weak var btn_stopLoading: UIBarButtonItem!
    @IBOutlet weak var btn_goForward: UIBarButtonItem!
    @IBOutlet weak var btn_goBack: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About Us"
        
        self.navigationController!.navigationBar.topItem!.title = "Back"
        
        let url = NSURL(string: "http://www.drxlr.com/about/")
        let request = NSURLRequest(url: url! as URL)
        webView.loadRequest(request as URLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
