//
//  InAppPurchaseProductId.swift
//  VitaSume
//
//  Created by Harold on 7/23/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

//
//  PKIAPHandler.swift
//
//  Created by Pramod Kumar on 13/07/2017.
//  Copyright © 2017 Pramod Kumar. All rights reserved.
//


import UIKit
import StoreKit

enum PKIAPHandlerAlertType {
    case setProductIds
    case disabled
    case restored
    case purchased
    
    var message: String{
        switch self {
        case .setProductIds: return "Product ids not set, call setProductIds method!"
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        }
    }
}


class PKIAPHandler: NSObject {
    
    //MARK:- Shared Object
    //MARK:-
    static let shared = PKIAPHandler()
    private override init() { }
    
    //MARK:- Properties
    //MARK:- Private
    fileprivate var productIds = [String](arrayLiteral: "resume_management_unlock")
    fileprivate var productID = "resume_management_unlock"
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var fetchProductcompletion: (([SKProduct])->Void)?
    
    fileprivate var productToPurchase: SKProduct?
    fileprivate var purchaseProductcompletion: ((PKIAPHandlerAlertType, SKProduct?, SKPaymentTransaction?)->Void)?
    
    //MARK:- Public
    var isLogEnabled: Bool = true
    
    //MARK:- Methods
    //MARK:- Public
    
    //Set Product Ids
    func setProductIds(ids: [String]) {
        self.productIds = ids
    }

    //MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchase(product: SKProduct, completion: @escaping ((PKIAPHandlerAlertType, SKProduct?, SKPaymentTransaction?)->Void)) {
        
        self.purchaseProductcompletion = completion
        self.productToPurchase = product

        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            log("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
        }
        else {
            completion(PKIAPHandlerAlertType.disabled, nil, nil)
        }
    }
    
    // RESTORE PURCHASE
    func restorePurchase() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    // FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(completion: @escaping (([SKProduct])->Void)){
        
        self.fetchProductcompletion = completion
        // Put here your IAP Products ID's
        if self.productIds.isEmpty {
            log(PKIAPHandlerAlertType.setProductIds.message)
            fatalError(PKIAPHandlerAlertType.setProductIds.message)
        }
        else {
            productsRequest = SKProductsRequest(productIdentifiers: Set(self.productIds))
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    //MARK:- Private
    fileprivate func log <T> (_ object: T) {
        if isLogEnabled {
            NSLog("\(object)")
        }
    }
}

//MARK:- Product Request Delegate and Payment Transaction Methods
//MARK:-
extension PKIAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    // REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            if let completion = self.fetchProductcompletion {
                completion(response.products)
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if let completion = self.purchaseProductcompletion {
            completion(PKIAPHandlerAlertType.restored, nil, nil)
            databaseManager.createData(setting: "PURCHASE_STATUS", value: "YES", uploadData: true) { returnDictionary in }
        } else {
            databaseManager.createData(setting: "PURCHASE_STATUS", value: "NO", uploadData: true) { returnDictionary in }
        }
    }
    
    // IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    case .purchased:
                        log("Product purchase done")
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        if let completion = self.purchaseProductcompletion {
                            databaseManager.createData(setting: "PURCHASE_STATUS", value: "YES", uploadData: true) { returnDictionary in }
                            databaseManager.createData(setting: "PURCHASE_DATE", value: getTimestamp(), uploadData: true) { returnDictionary in }
                            DispatchQueue.main.async {
                                let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                                rootViewController?.present(alert(title: "Successful Activation!\n\nEnjoy unlimited resume management.", message: "", buttonText: "OK"), animated: true)
                            }
                            completion(PKIAPHandlerAlertType.purchased, self.productToPurchase, trans)
                        }
                        break
                        
                    case .failed:
                        log("Product purchase failed")
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        break
                    case .restored:
                        log("Product restored")
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        break
                        
                    default: break
                }
            }
        }
    }
}
