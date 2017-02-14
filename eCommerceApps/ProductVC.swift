//
//  ProductVC.swift
//  eCommerceApps
//
//  Created by Luthfi Fathur Rahman on 2/2/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire
import Gloss
import ImageSlideshow

class ProductVC: UIViewController {

    var ProductName: String!
    var prodID: String = "0"
    var Prod_pict1: String = ""
    var AddDeleteWishlist: String = ""
    
    @IBOutlet weak var Prod_name: UILabel!
    @IBOutlet weak var Prod_picts: ImageSlideshow!
    @IBOutlet weak var Prod_price: UILabel!
    @IBOutlet weak var Prod_Add2Cart: UIButton!
    @IBOutlet weak var Prod_Add2Wishlist: UIButton!
    @IBOutlet weak var min_purchase: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var stock: UILabel!
    @IBOutlet weak var Prod_desc: UITextView!
    
    //struct yang dipakai dari Gloss
    struct detailProduk: Decodable{
        let prodID: String?
        let prodName: String?
        let prodPrice: String?
        let prodPict1: String?
        let prodPict2: String?
        let prodPict3: String?
        let prodInfoMinBuy: String?
        let prodInfoWeight: String?
        let prodInfoCondition: String?
        let prodDesc: String?
        let prodStock: String?
        
        init?(json: JSON){
            self.prodID = "id" <~~ json
            self.prodName = "name" <~~ json
            self.prodPrice = "price" <~~ json
            self.prodPict1 = "pict1" <~~ json
            self.prodPict2 = "pict2" <~~ json
            self.prodPict3 = "pict3" <~~ json
            self.prodInfoMinBuy = "info_minBuy" <~~ json
            self.prodInfoWeight = "info_weight" <~~ json
            self.prodInfoCondition = "info_condition" <~~ json
            self.prodDesc = "desc" <~~ json
            self.prodStock = "info_stock" <~~ json
        }
    }
    
    struct Wishlist_result : Decodable {
        let result: String?
        init?(json: JSON) {
            self.result = "result" <~~ json
        }
    }
    
    let userdefault = UserDefaults.standard
    let productCart = Gorobak.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.topItem!.title = "Back"
        
        Prod_Add2Cart.layer.cornerRadius = 5
        Prod_Add2Wishlist.layer.cornerRadius = 5
        Prod_Add2Cart.isEnabled = false
        Prod_Add2Wishlist.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (ProductName.range(of: " ") != nil) {
            ProductName = ProductName.replacingOccurrences(of: " ", with: "%20")
        }
        
        let userID = userdefault.object(forKey: "userid") as? String
        if (userID != nil) {
            get_data_from_url(url: BaseURL.rootURL()+"produkdetail.php?produk=\(ProductName!)&userid=\(userID!)")
            Alamofire.request(BaseURL.rootURL()+"check_wishlist.php?userid=\(userID!)&prodname=\(ProductName!)", method:.get).validate(contentType: ["application/json"]).responseJSON{ response in
                switch response.result{
                case .success(let data):
                    guard let value = data as? JSON,
                        let eventsArrayJSON = value["wishlist"] as? [JSON]
                        else { fatalError() }
                    let wishlist = [Wishlist_result].from(jsonArray: eventsArrayJSON)
                    for j in 0 ..< Int((wishlist?.count)!){
                        //print(wishlist[j].result!)
                        if ((wishlist?[j].result!)! == "Product is in your wishlist.") {
                            self.Prod_Add2Wishlist.setTitle("Delete From Wishlist", for: .normal)
                        } else {
                            self.Prod_Add2Wishlist.setTitle("Add To Wishlist", for: .normal)
                        }
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    let alert3 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert3.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert3, animated: true, completion: nil)
                }
            }
        } else {
            get_data_from_url(url: BaseURL.rootURL()+"produkdetail.php?produk=\(ProductName!)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func get_data_from_url(url:String){
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
                    let eventsArrayJSON = value["ProdukDetail"] as? [JSON]
                    else { fatalError() }
                let DetailProduk = [detailProduk].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((DetailProduk?.count)!) {
                    self.prodID = (DetailProduk?[j].prodID!)!
                    self.Prod_name.text = DetailProduk?[j].prodName!
                    self.Prod_name.font = UIFont(name: self.Prod_name.font.fontName, size: 30)
                    self.Prod_name.adjustsFontSizeToFitWidth = true
                    //untuk slideshow gambar produk: Start
                    self.Prod_pict1 = (DetailProduk?[j].prodPict1!)!
                    let afNetworkingSource = [AFURLSource(urlString: (DetailProduk?[j].prodPict1!)!)!, AFURLSource(urlString: (DetailProduk?[j].prodPict2!)!)!, AFURLSource(urlString: (DetailProduk?[j].prodPict3!)!)!]
                    self.Prod_picts.backgroundColor = UIColor.clear
                    self.Prod_picts.slideshowInterval = 0.0
                    self.Prod_picts.pageControlPosition = PageControlPosition.insideScrollView
                    self.Prod_picts.pageControl.currentPageIndicatorTintColor = UIColor.lightGray;
                    self.Prod_picts.pageControl.pageIndicatorTintColor = UIColor.black;
                    self.Prod_picts.contentScaleMode = UIViewContentMode.scaleAspectFill
                    self.Prod_picts.setImageInputs(afNetworkingSource)
                    //untuk slideshow gambar produk: End
                    self.Prod_price.text = (DetailProduk?[j].prodPrice!)!
                    self.Prod_price.font = UIFont(name: self.Prod_price.font.fontName, size: 20)
                    self.Prod_price.adjustsFontSizeToFitWidth = true
                    self.min_purchase.text = DetailProduk?[j].prodInfoMinBuy!
                    self.min_purchase.sizeToFit()
                    self.weight.text = DetailProduk?[j].prodInfoWeight!
                    self.weight.sizeToFit()
                    self.condition.text = DetailProduk?[j].prodInfoCondition!
                    self.condition.sizeToFit()
                    self.stock.text = DetailProduk?[j].prodStock!
                    self.stock.sizeToFit()
                    if (DetailProduk?[j].prodStock! == "0") {
                        self.Prod_Add2Cart.isEnabled = false
                        self.Prod_Add2Cart.backgroundColor = UIColor.darkGray
                    } else {
                        self.Prod_Add2Cart.isEnabled = true
                        self.Prod_Add2Cart.backgroundColor = UIColor(red: 116.0/255.0, green: 212.0/255.0, blue: 50.0/255.0, alpha: 1.0)
                    }
                    self.Prod_desc.text = DetailProduk?[j].prodDesc!
                    //self.Prod_desc.sizeToFit()
                    self.Prod_Add2Cart.isEnabled = true
                    self.Prod_Add2Wishlist.isEnabled = true
                }
                break
            case .failure(let error):
                self.dismiss(animated: false, completion: nil)
                print("Error: \(error)")
                let alert = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func Add_Delete_Wishlist(_ sender: UIButton) {
        if ((userdefault.object(forKey: "loginStatus") as? Bool != nil) && (userdefault.object(forKey: "userid") as? String != nil)) {
            if (self.Prod_Add2Wishlist.currentTitle! == "Delete From Wishlist") {
                self.AddDeleteWishlist = "delete"
                //print("ProdukID=\(self.prodID)")
                Alamofire.request("https://imperio.co.id/project/ecommerceApp/add_remove_wishlist.php?userid=\((self.userdefault.object(forKey: "userid") as? String)!)&prodid=\(self.prodID)&wishlist_status=\(self.AddDeleteWishlist)").validate(contentType: ["text/html"]).responseString{ response in
                    switch response.result {
                    case .success(let data):
                        if ( data == "The product has been removed from your wishlist."){
                            self.Prod_Add2Wishlist.setTitle("Add To Wishlist", for: .normal)
                        } else {
                            let alertWL = UIAlertController (title: "Error Deleting Product From Wishlist", message: data, preferredStyle: UIAlertControllerStyle.alert)
                            alertWL.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertWL, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                        let alert1 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alert1, animated: true, completion: nil)
                    }
                }
            } else if (self.Prod_Add2Wishlist.currentTitle! == "Add To Wishlist") {
                self.AddDeleteWishlist = "add"
                Alamofire.request("https://imperio.co.id/project/ecommerceApp/add_remove_wishlist.php?userid=\((self.userdefault.object(forKey: "userid") as? String)!)&prodid=\(self.prodID)&wishlist_status=\(self.AddDeleteWishlist)").validate(contentType: ["text/html"]).responseString{ response in
                    switch response.result {
                    case .success(let data):
                        if ( data == "The product has been added to your wishlist."){
                            self.Prod_Add2Wishlist.setTitle("Delete From Wishlist", for: .normal)
                        } else {
                            let alertWL = UIAlertController (title: "Error Adding Product To Wishlist", message: data, preferredStyle: UIAlertControllerStyle.alert)
                            alertWL.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertWL, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                        let alert2 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert2.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alert2, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let alertWL = UIAlertController (title: "Error Adding Product To Wishlist", message: "Please login to add this product to your wishlist.", preferredStyle: UIAlertControllerStyle.alert)
            alertWL.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertWL, animated: true, completion: nil)
        }
    }
    
    @IBAction func Add2Cart(_ sender: UIButton) {
        if self.productCart.isProductInCart(self.Prod_name.text!) {
            let alertA2C = UIAlertController (title: "Shopping Cart", message: "The product is already in your shopping cart.", preferredStyle: UIAlertControllerStyle.alert)
            alertA2C.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertA2C, animated: true, completion: nil)
        } else {
            self.productCart.addProduct(self.prodID, prodName: self.Prod_name.text!, prodPrice: self.Prod_price.text!, imageURL: self.Prod_pict1, stock: self.stock.text!, weight: self.weight.text!)
            let alertA2C = UIAlertController (title: "Shopping Cart", message: "The Product has been added to your shopping cart.", preferredStyle: UIAlertControllerStyle.alert)
            alertA2C.addAction(UIAlertAction(title: "Go To Shopping Cart", style: UIAlertActionStyle.default,handler: {(action) in
                self.tabBarController?.selectedIndex = 1
            }))
            alertA2C.addAction(UIAlertAction(title: "Continue Shopping", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertA2C, animated: true, completion: nil)
        }
    }

}
