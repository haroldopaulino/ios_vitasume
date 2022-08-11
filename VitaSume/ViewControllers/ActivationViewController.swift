//
//  ActivateViewController.swift
//  iResume
//
//  Created by Harold on 6/22/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import UIKit
import StoreKit

class ActivationViewController: UIViewController {
    
    @IBOutlet var activationMainView: UIView!
    @IBOutlet weak var activateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var descriptionLine2: UILabel!
    
    var delegate: ActivationDelegate?
    let databaseManager = DatabaseManager()
    
    var productIDs = [String](arrayLiteral: "resume_management_unlock")
    var inAppProducts = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonsStyle()
        manageButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func loadPurchaseData() {
        PKIAPHandler.shared.setProductIds(ids: self.productIDs)
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products) in
            self!.inAppProducts = products
            
            self!.purchaseActivation()
        }
        PKIAPHandler.shared.restorePurchase()
    }
     
     func purchaseActivation() {
        self.removeSpinner()
         PKIAPHandler.shared.purchase(product: self.inAppProducts[0]) { (alert, product, transaction) in
            /*if let tran = transaction, let prod = product {
                //use transaction details and purchased product as you want
            }
            let purchaseMessage = alert.message*/
         }
     }
    
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for: SKProduct) -> Bool {
        return true
    }
    
    func manageButtons() {
        if wasAppPurchased() {
            activateButton.isHidden = true
            cancelButton.setTitle("ok", for: UIControl.State.normal)
        } else {
            let currentAppInstallDays = appInstallDays()
            
            if currentAppInstallDays <= appTrialPeriodInDays {
                descriptionLine2.text = "Your free trial expires in \(appTrialPeriodInDays - currentAppInstallDays) days."
            } else {
                descriptionLine2.text = "Your free trial expired \(currentAppInstallDays - appTrialPeriodInDays) days ago."
            }
        }
    }
    
    func buttonsStyle() {
        activateButton.layer.cornerRadius = 5
        activateButton.layer.borderWidth = 1
        activateButton.layer.borderColor = UIColor.white.cgColor
        
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.white.cgColor
    }
    
    func setupView() {
        activationMainView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        activationMainView.alpha = 0;
        activationMainView.frame.origin.y = self.activationMainView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.activationMainView.alpha = 1.0;
            self.activationMainView.frame.origin.y = self.activationMainView.frame.origin.y - 50
        })
    }
    
    func requestLogin() {
        /*httpRequest(data: [
            "action": "REGISTER".toBase64(),
            "name": nameTextfield.text!.toBase64(),
            "email": emailTextfield.text!.toBase64(),
            "phone_number": phoneTextfield.text!.toBase64(),
            "social_media": socialMediaTextfield.text!.toBase64(),
            "password": passwordTextfield.text!.toBase64(),
            "client_datetime": getTimestamp().toBase64()]){ (returnDict) in
                self.processPasswordChangeData(data: returnDict!)
        }*/
    }
    
    @IBAction func activateButtonTouchUpInside(_ sender: Any) {
        self.showSpinner(onView: self.view)
        loadPurchaseData()
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        delegate?.cancelActivation()
        self.dismiss(animated: true, completion: nil)
    }
}
