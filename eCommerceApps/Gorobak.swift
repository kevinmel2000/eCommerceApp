//
//  ShoppingCart.swift
//  Gorobak
//
//  Created by Luthfi Fathur Rahman on 12/13/16.
//  Copyright © 2016 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class Gorobak: NSObject {
    //initialize custom var for the product.
    public struct ProductObject {
        //initialize variables for the product's properties, you can adjust these variables to meet your need.
        var prodID: String
        var prodName: String
        var prodPrice: String
        var imageURL: String
        var qty: Int
        var stock: String
        var weight: String
        
        init(prodID: String, prodName: String, prodPrice: String, imageURL: String, qty: Int, stock: String, weight: String){
            self.prodID = prodID
            self.prodName = prodName
            self.prodPrice = prodPrice
            self.imageURL = imageURL
            self.qty = qty
            self.stock = stock
            self.weight = weight
        }
        
        //the function to convert this product struct into a dictionary. It'll be called before convert the product array into JSON. It will be useful if you need to send the product data over the internet to your server.
        func convertToDictionary() -> [String : Any] {
            let dic: [String: Any] = ["prodID":self.prodID, "prodName":self.prodName, "prodPrice":self.prodPrice, "imageURL":self.imageURL, "qty":self.qty, "stock":self.stock, "weight":self.weight]
            return dic
        }
    }
    
    //initialize the private variables for this class.
    fileprivate var productsArray = [ProductObject]()
    fileprivate var shippingcost = ""
    fileprivate var shipper = ""
    fileprivate var shipperService = ""
    fileprivate var tax = 0.0
    
    //initialize the singleton to use this class in the other classes.
    class var sharedInstance: Gorobak {
        struct Static {
            static var instance: Gorobak? = Gorobak()
        }
        return Static.instance!
    }
    
    //the function to add a product into productsArray.
    func addProduct(_ prodID: String, prodName: String, prodPrice: String, imageURL: String, stock: String, weight: String) {
        let qty = 1 //quantity default value is 1. You better change it in shopping cart table, instead give its values in the product page.
        let product1 = ProductObject(prodID: prodID, prodName: prodName, prodPrice: prodPrice, imageURL: imageURL, qty: qty, stock: stock, weight: weight)
        productsArray.append(product1)
        //print(productsArray) //you can check whether the product is added successfully into the productsArray.
    }
    
    //the function to remove a product from productsArray.
    func removeProduct(_ product: ProductObject)-> Bool {
        if let index = productsArray.index(where: {$0.prodName == product.prodName}) {
            productsArray.remove(at: index)
            //print(productsArray) //you can check whether the product is removed from the productsArray.
            return true //it will return true if the product is successfully removed.
        }
        return false //it will false true if the product is failed to removed.
    }
    
    //the function to get the currency code that you use. For e.g. "USD 9.99", it'll return "USD".
    func getCurrencyCode()-> String {
        if !productsArray.isEmpty {
            let product = productsArray[0] //only need sample from one product to decide the currency that user uses.
            let price = product.prodPrice
            let priceIndex = price.range(of: " ", options: .backwards)?.lowerBound
            return price.substring(to: priceIndex!)
        } else {
            return ""
        }
    }
    
    //the function to update product quatity.
    func updateProductQty(_ productName: String, newQty: Int) {
        if let index = productsArray.index(where: {$0.prodName == productName}) {
            let oldQty = productsArray[index].qty
            if oldQty != newQty {
                productsArray[index].qty = newQty
            } else {
                productsArray[index].qty = oldQty
            }
            //print(productsArray) //you can check whether the product's property is updated in productsArray.
        }
    }
    
    //the function to calculate the total price in this cart.
    func totalPriceInCart() -> Double {
        var totalPrice: Double = 0
        for product in productsArray {
            let price = product.prodPrice
            let priceIndex = price.range(of: " ", options: .backwards)?.lowerBound
            var priceNumber = price.substring(from: priceIndex!)
            priceNumber = removeSpecialCharsFromString(priceNumber)
            let subtotalPrice = Double(priceNumber)! * Double(product.qty)
            totalPrice += subtotalPrice
        }
        return totalPrice
    }
    
    //the function to calculate the total products' weight in this cart.
    func totalWeightInCart() -> Int {
        var totalWeight: Int = 0
        for product in productsArray {
            let weight = (product.weight as NSString).integerValue * product.qty
            totalWeight += weight
        }
        return totalWeight
    }
    
    //the function to save shipper name, shipper service and shipping cost. The new data that you input will be overwrite the currently saved data, because you can only choose 1 shipper and its service.
    func AddShippingCost(_ shipperName: String, service: String, cost: String) {
        shipper = shipperName
        shipperService = service
        shippingcost = cost
    }
    
    //the function to get shipping cost data. It only return the shipping cost numbers. For e.g. the shipping cost is "USD 4.99", it'll return "4.99". It'll be use in calculation to get the grand total price the user has to pay.
    func getShippingCost() -> Double {
        let price = shippingcost
        if (price != "") {
            let priceIndex = price.range(of: " ", options: .backwards)?.lowerBound
            var priceStr = price.substring(from: priceIndex!)
            priceStr = removeSpecialCharsFromString(priceStr)
            return (priceStr as NSString).doubleValue
        } else {
            return 0
        }
    }
    
    //the function to get the data of shipper name and its service. It'll be put in invoice.
    func getShipperData ()-> (String, String) {
        return (shipper, shipperService)
    }
    
    //the function to calculate the tax, 10% of the user's subtotal price (the sum up of the price of the products that user buys).
    func calculateTax(_ state: Bool) -> Double {
        switch  state {
        case true:
            tax = (Double(totalPriceInCart())*0.1) //change this number if you want the difference tax percentage.
            return tax
        case false:
            tax = 0.0
            return tax
        }
    }
    
    //the function to retrieve the tax value.
    func getTax()->Double {
        return tax
    }
    
    //the function to get the product data. It is usally use in shopping cart table.
    func productAtIndexPath(_ indexPath: IndexPath) -> ProductObject {
        return productsArray[indexPath.row]
    }
    
    //the function to get the product data. It is usually use in anywhere but shopping cart table.
    func getAllProduct(_ atIndex: Int) ->ProductObject {
        return productsArray[atIndex]
    }
    
    //the function to get the amount of items in cart.
    func numberOfItemsInCart() -> Int {
        return productsArray.count
    }
    
    //the function to remove all products data in cart.
    func deleteAllDataInCart() {
        productsArray.removeAll(keepingCapacity: false)
    }
    
    //the function to check whether a product is in the cart or not.
    func isProductInCart(_ productName: String) -> Bool {
        return productsArray.contains(where: {$0.prodName == productName}) //it will return true if the product is in the cart, and return false if it is not.
    }
    
    //the function to remove the chars that you dont allow in the product data.
    func removeSpecialCharsFromString(_ text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890.".characters) //put all the chars that you allow in this line inside the "".
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    //the function to prepare the ProductArray to be converted into JSON. Use this function before you send these data over the internet.
    func prepareForConvesionToJSON()-> [[String:Any]] {
        let dicArray = productsArray.map { $0.convertToDictionary() }
        return dicArray
    }
}
