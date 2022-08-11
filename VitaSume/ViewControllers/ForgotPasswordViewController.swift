//
//  ForgotPasswordViewController.swift
//  iResume
//
//  Created by Harold on 6/11/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet var forgotPasswordMainView: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var delegate: ForgotPasswordDelegate?
    let databaseManager = DatabaseManager()
    var mode = "request_reset_code"
    var email = ""
    var code = ""
    var newPassword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.becomeFirstResponder()
        hidePassword()
        buttonsStyle()
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
    
    func buttonsStyle() {
        resetButton.layer.cornerRadius = 5
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = UIColor.white.cgColor
        
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.white.cgColor
    }
    
    func setupView() {
        forgotPasswordMainView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        if (databaseManager.getData(setting: "LOGGED_IN").decrypt()?.elementsEqual("YES"))! {
            emailTextfield.text = databaseManager.getData(setting: "LOGGED_IN_USERNAME").decrypt()
        }
    }
    
    func animateView() {
        forgotPasswordMainView.alpha = 0;
        forgotPasswordMainView.frame.origin.y = self.forgotPasswordMainView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.forgotPasswordMainView.alpha = 1.0;
            self.forgotPasswordMainView.frame.origin.y = self.forgotPasswordMainView.frame.origin.y - 50
        })
    }
    
    func showPassword() {
        DispatchQueue.main.async {
            self.passwordLabel.isHidden = false
            self.passwordTextfield.isHidden = false
        }
    }
    
    func hidePassword() {
        DispatchQueue.main.async {
            self.passwordLabel.isHidden = true
            self.passwordTextfield.isHidden = true
        }
    }
    
    func displayCodeVerification(data: [String:String]) {
        if let returnValue = data["return"] {
            if returnValue.elementsEqual("BAD") {
                DispatchQueue.main.async {
                    self.present(alert(title: "Error", message: data["message"] ?? "Communication Error", buttonText: "OK"), animated: true)
                }
            } else {
                mode = "verify_reset_code"
                DispatchQueue.main.async {
                    self.emailTextfield.attributedPlaceholder = NSAttributedString(string: "verification code", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
                    
                    self.emailLabel.text = "code"
                    self.emailTextfield.text = ""
                    self.emailTextfield.isUserInteractionEnabled = true
                    self.emailTextfield.becomeFirstResponder()
                    self.hidePassword()
                    self.resetButton.setTitle("verify", for: .normal)
                    
                    self.present(alert(title: "Check your email", message: "The verification code has been emailed to you", buttonText: "I'll check my email"), animated: true)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func displayPasswordChange() {
        mode = "change_password"
        DispatchQueue.main.async {
            self.emailLabel.text = "email"
            self.emailTextfield.text = self.email
            self.emailTextfield.resignFirstResponder()
            self.emailTextfield.isUserInteractionEnabled = false
            self.showPassword()
            self.passwordTextfield.text = ""
            self.passwordTextfield.becomeFirstResponder()
            self.resetButton.setTitle("finish", for: .normal)
        }
    }
    
    func processCodeVerificationData(data: [String:String]) {
        if let returnValue = data["return"] {
            if returnValue.elementsEqual("BAD") {
                DispatchQueue.main.async {
                    self.present(alert(title: "Error", message: data["message"] ?? "Communication Error", buttonText: "OK"), animated: true)
                }
            } else {
                displayPasswordChange()
            }
        }
    }
    
    func processPasswordChangeData(data: [String:String]) {
        if let returnValue = data["return"] {
            if returnValue.elementsEqual("BAD") {
                present(alert(title: "Error", message: data["message"] ?? "Communication Error", buttonText: "OK"), animated: true)
            } else {
                DispatchQueue.main.async {
                    let changePasswordEmail = self.databaseManager.getData(setting: "CHANGE_PASSWORD_EMAIL").decrypt()
                    let changePasswordNewPassword = self.databaseManager.getData(setting: "CHANGE_PASSWORD_NEW_PASSWORD").decrypt()
                    self.databaseManager.createData(setting: "LOGGED_IN", value: "YES".encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    self.databaseManager.createData(setting: "LOGGED_IN_USERNAME", value: changePasswordEmail!.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    self.databaseManager.createData(setting: "LOGGED_IN_PASSWORD", value: changePasswordNewPassword!.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    
                    self.emailTextfield.resignFirstResponder()
                    self.passwordTextfield.resignFirstResponder()
                    
                    let alert = UIAlertController(title: data["message"], message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "got it", style: .default, handler: { action in
                        self.emailTextfield.resignFirstResponder()
                        self.passwordTextfield.resignFirstResponder()
                        self.delegate?.finishForgotPassword(email: self.email, code: self.code, newPassword: self.newPassword)
                        self.dismiss(animated: true, completion: nil)
                    }))

                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func requestResetPasswordCode() {
        email = emailTextfield.text!
        self.databaseManager.createData(setting: "CHANGE_PASSWORD_EMAIL", value: email.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
        self.showSpinner(onView: self.view)
        httpRequest(data: [
                "action": "RESET_PASSWORD".toBase64(),
                "client_datetime": getTimestamp().toBase64(),
                "email": email.toBase64()]) { (returnDict) in
            self.removeSpinner()
            self.displayCodeVerification(data: returnDict!)
        }
    }
    
    func requestResetPasswordCodeVerification() {
        code = emailTextfield.text!
        self.showSpinner(onView: self.view)
        httpRequest(data: [
                "action": "RESET_PASSWORD".toBase64(),
                "client_datetime": getTimestamp().toBase64(),
                "email": email.toBase64(),
                "reset_code": code.toBase64()]) { (returnDict) in
            self.removeSpinner()
            self.processCodeVerificationData(data: returnDict!)
        }
    }
    
    func requestChangePassword() {
        newPassword = passwordTextfield.text!
        self.databaseManager.createData(setting: "CHANGE_PASSWORD_NEW_PASSWORD", value: newPassword.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
        self.showSpinner(onView: self.view)
        httpRequest(data: [
                "action": "RESET_PASSWORD".toBase64(),
                "client_datetime": getTimestamp().toBase64(),
                "email": email.toBase64(),
                "reset_code": code.toBase64(),
                "new_password": newPassword.toBase64()]) { (returnDict) in
            self.removeSpinner()
            self.processPasswordChangeData(data: returnDict!)
        }
    }
    
    @IBAction func resetButtonTouchUpInside(_ sender: Any) {
        if mode.elementsEqual("request_reset_code") {
            requestResetPasswordCode()
            return
        }
        
        if mode.elementsEqual("verify_reset_code") {
            requestResetPasswordCodeVerification()
            return
        }
        
        if mode.elementsEqual("change_password") {
            requestChangePassword()
            return
        }
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        emailTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        delegate?.cancelForgotPassword()
        self.dismiss(animated: true, completion: nil)
    }
    
}

