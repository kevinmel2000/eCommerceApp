//
//  WishlistVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 2/2/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class WishlistVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var TableData:Array<String> = Array <String>()
    let userdefault = UserDefaults.standard
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn_refresh: UIBarButtonItem!
    
    struct daftarProduk: Decodable{
        let prodID: Int?
        let prodName: String?
        let Query_Status: String?
        
        init?(json: JSON){
            self.prodID = "id" <~~ json
            self.prodName = "name" <~~ json
            self.Query_Status = "query_status" <~~ json
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Wishlist"
        checkEmptyStateOfList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if ((userdefault.object(forKey: "loginStatus") as? Bool != nil) && (userdefault.object(forKey: "userid") as? String != nil)) {
            if (userdefault.object(forKey: "loginStatus") as? Bool != false) {
                get_data_from_url(url: "https://imperio.co.id/project/ecommerceApp/show_wishlist.php")
            }
        } else {
            let alertStatus = UIAlertController (title: "eCommerce App Message", message: "Please log in to access this page.", preferredStyle: UIAlertControllerStyle.alert)
            alertStatus.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:  {(action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertStatus, animated: true, completion: nil)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        // #warning Incomplete implementation, return the number of rows
        return TableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishlistCell", for: indexPath)
        
        cell.textLabel?.text = TableData[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        if(((currentCell.textLabel!.text) != "") && ((currentCell.textLabel!.text) != nil)){
            performSegue(withIdentifier: "SegueWishlistToProduct", sender: self)
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let prodVc = segue.destination as! ProductVC
        if segue.identifier == "SegueWishlistToProduct"{
            if let indexPath = self.tableView.indexPathForSelectedRow {
                // get the cell associated with the indexPath selected.
                let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
                prodVc.ProductName = (currentCell.textLabel!.text)! as String
            }
        }
    }
    
    func checkEmptyStateOfList() {
        setEmptyViewVisible(visible: TableData.count == 0)
    }
    
    func setEmptyViewVisible(visible: Bool) {
        emptyView.isHidden = !visible
        if visible {
            self.view.bringSubview(toFront: emptyView)
        } else {
            self.view.sendSubview(toBack: emptyView)
        }
    }
    
    //untuk ngambil data dari server
    func get_data_from_url(url:String){
        self.TableData.removeAll(keepingCapacity: false)
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
                    let eventsArrayJSON = value["wishlist"] as? [JSON]
                    else { fatalError() }
                let DaftarProduk = [daftarProduk].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((DaftarProduk?.count)!){
                    self.TableData.append((DaftarProduk?[j].prodName!)!)
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        self.checkEmptyStateOfList()
                    })
                }
                break
            case .failure(let error):
                self.dismiss(animated: false, completion: nil)
                print("Error: \(error)")
                let alert1 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert1, animated: true, completion: nil)
                break
            }
        }
    }
    
    @IBAction func btn_refresh(_ sender: UIBarButtonItem) {
        get_data_from_url(url: "https://imperio.co.id/project/ecommerceApp/show_wishlist.php")
    }
    

}
