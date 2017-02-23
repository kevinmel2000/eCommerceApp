//
//  ViewController.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 1/26/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Gloss
import Alamofire
import ImageSlideshow

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var view_imageslideshow: ImageSlideshow!
    @IBOutlet weak var tableView: UITableView!
    
    //struct yang dipakai dari Gloss Untuk Promo Banners
    struct PromoBanners: Decodable{
        let promoID: Int?
        let promoBanner: String?
        
        init?(json: JSON){
            self.promoID = "id" <~~ json
            self.promoBanner = "banner" <~~ json
        }
    }
    
    struct daftarProduk: Decodable{
        let prodID: String?
        let prodName: String?
        let prodCat: String?
        
        init?(json: JSON){
            self.prodID = "id" <~~ json
            self.prodName = "name" <~~ json
            self.prodCat = "category" <~~ json
        }
    }
    
    var sections:Array<String> = Array <String>()
    var items = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == false {
            let alert1 = UIAlertController (title: "Internet Connection Error", message: "This app requires internet connection to be used. Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert1.addAction(UIAlertAction(title: "Close App", style: UIAlertActionStyle.default,handler: {(action) in
                exit(0)
            }))
            self.present(alert1, animated: true, completion: nil)
        } else {
            get_data_for_banners(url: BaseURL.rootURL()+"promobanners.php")
            get_data_from_url(url: BaseURL.rootURL()+"allproducts.php")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section == 0 {
            let cell0 = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! HomeTVC
            view_imageslideshow.frame = CGRect.init(x: cell0.frame.origin.x, y: cell0.frame.origin.y, width: cell0.frame.width, height: 200)
            view_imageslideshow.center = cell0.center
            cell0.contentView.addSubview(view_imageslideshow)
            
            return cell0
        } else {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! HomeTVC
            cell1.backgroundColor = UIColor(red: 209.0/255.0, green: 26.0/255.0, blue: 81.0/255.0, alpha: 1.0)
            cell1.prodNameLabel.text = self.items[indexPath.section][indexPath.row]//kadang2 baris kode ini bikin error, belum diketahu penyababnya.
            cell1.prodNameLabel.textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            cell1.imageProd.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            cell1.accessoryType = .disclosureIndicator
            
            return cell1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 && indexPath.section == 0 {
            return 200 //height for imageslideshow
        } else {
            return 110.0 //Choose your custom row height
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SegueProd", sender: self)
    }
    
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
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let prodVc = segue.destination as! ProductVC
        if segue.identifier == "SegueProd"{
            if let indexPath = self.tableView.indexPathForSelectedRow {
                // get the cell associated with the indexPath selected.
                let currentCell = tableView.cellForRow(at: indexPath)! as! HomeTVC
                prodVc.ProductName = currentCell.prodNameLabel.text! as String
            }
        }
    }

    func get_data_for_banners(url:String){
        Alamofire.request(url, method:.get).validate(contentType: ["application/json"]).responseJSON{ response in
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
                    let eventsArrayJSON = value["PromoBanners"] as? [JSON]
                    else { fatalError() }
                let PromoBannersVar = [PromoBanners].from(jsonArray: eventsArrayJSON)
                //untuk slideshow gambar produk: Start
                var afNetworkingSource = [AFURLSource]()
                for j in 0 ..< Int((PromoBannersVar?.count)!) {
                    afNetworkingSource.append(AFURLSource(urlString: (PromoBannersVar?[j].promoBanner!)!)!)
                }
                self.view_imageslideshow?.backgroundColor = UIColor.clear
                self.view_imageslideshow?.slideshowInterval = 5.0
                self.view_imageslideshow?.pageControlPosition = PageControlPosition.insideScrollView
                self.view_imageslideshow?.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
                self.view_imageslideshow?.pageControl.pageIndicatorTintColor = UIColor.black
                self.view_imageslideshow?.contentScaleMode = UIViewContentMode.scaleAspectFill
                self.view_imageslideshow?.draggingEnabled = true
                self.view_imageslideshow?.setImageInputs(afNetworkingSource)
                
                //untuk slideshow gambar produk: End
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
    
    func get_data_from_url(url:String){
        sections.removeAll(keepingCapacity: false)
        items.removeAll(keepingCapacity: false)
        self.sections.append("")
        self.items.append([""])
        Alamofire.request(url, method:.get).validate(contentType: ["application/json"]).responseJSON{ response in
            switch response.result{
            case .success(let data):
                guard let value = data as? JSON,
                    let eventsArrayJSON = value["prodlist"] as? [JSON]
                    else { fatalError() }
                let DaftarProduk = [daftarProduk].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((DaftarProduk?.count)!){
                    self.sections.append((DaftarProduk?[j].prodCat!)!)
                }
                self.sections = self.removeDuplicates(array: self.sections)
                print("sections = \((DaftarProduk?.endIndex)!)")
                
                //lakukan pengulangan sebanyak jumlah isi array sections.
                var tempArr = [String]()
                for k in 0 ..< self.sections.count{
                    if self.sections[k] != "" {
                        //lakukan pengulangan sebanyak isi array DaftarProduk
                        for l in 0 ..< Int((DaftarProduk?.count)!){
                            tempArr.removeAll(keepingCapacity: false)
                            while (DaftarProduk?[l].prodCat!)! == self.sections[k] {
                                if self.items.indices.contains(k) {
                                    self.items[k].append((DaftarProduk?[l].prodName!)!)
                                } else {
                                    self.items.append([(DaftarProduk?[l].prodName!)!])
                                }
                                break
                            }
                        }
                    }
                }
                
                print("jumlah items: \(self.items.count)")
                //print("isi items: \(self.items)")
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                break
            case .failure(let error):
                print("Error: \(error)")
                let alert2 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert2.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert2, animated: true, completion: nil)
                break
            }
        }
    }
    
    func removeDuplicates(array: [String])->[String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                // Do not add a duplicate element.
            }
            else {
                encountered.insert(value)
                result.append(value)
            }
        }
        return result
    }
}

