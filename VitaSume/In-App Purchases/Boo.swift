//
//  Boo.swift
//  VitaSume
//
//  Created by Harold on 7/24/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import StoreKit

class MyStoreKitDelegate: NSObject {
    
    let monthlySubID = "resume_management_unlock"
    var products: [String: SKProduct] = [:]
    
    func fetchProducts() {
        let productIDs = Set([monthlySubID])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func purchase(productID: String) {
        if let product = products[productID] {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension MyStoreKitDelegate: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.invalidProductIdentifiers.forEach { product in
            print("Invalid: \(product)")
        }
        
        response.products.forEach { product in
            print("Valid: \(product)")
            products[product.productIdentifier] = product
        }
    }
    
    private func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error for request: \(error.localizedDescription)")
    }
    
}
