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
        let prodID: Int?
        let prodName: String?
        let prodCat: String?
        
        init?(json: JSON){
            self.prodID = "id" <~~ json
            self.prodName = "name" <~~ json
            self.prodCat = "category" <~~ json
        }
    }
    
    let sections:Array<String> = Array <String>()
    let items = [[String:String]]()
    
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
        get_data_for_banners(url: "https://imperio.co.id/project/ecommerceApp/promobanners.php")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        
        //cell.textLabel?.text = self.items[indexPath.section][indexPath.row]
        cell.accessoryType = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 134.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
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

    func get_data_for_banners(url:String){
        Alamofire.request(url, method:.get).validate(contentType: ["application/json"]).responseJSON{ response in
            switch response.result{
            case .success(let data):
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
                print("Error: \(error)")
                let alert1 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert1, animated: true, completion: nil)
                break
            }
        }
    }
    
    func get_data_from_url(url:String){
        //TableData.removeAll(keepingCapacity: false)
        Alamofire.request(url, method:.get).validate(contentType: ["application/json"]).responseJSON{ response in
            //print(response.result.value)
            switch response.result{
            case .success(let data):
                guard let value = data as? JSON,
                    let eventsArrayJSON = value["prodlist"] as? [JSON]
                    else { fatalError() }
                let DaftarProduk = [daftarProduk].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((DaftarProduk?.count)!){
                    //self.TableData.append((DaftarProduk?[j].prodName!)!)
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                break
            case .failure(let error):
                print("Error: \(error)")
                break
            }
        }
    }
}

