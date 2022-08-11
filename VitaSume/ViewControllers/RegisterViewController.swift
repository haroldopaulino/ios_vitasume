//
//  RegisterViewController.swift
//  iResume
//
//  Created by Harold on 6/2/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    
    @IBOutlet var registerMainView: UIView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var socialMediaTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var delegate: RegisterDelegate?
    let databaseManager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextfield.becomeFirstResponder()
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
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor.white.cgColor
        
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.white.cgColor
    }
    
    func setupView() {
        registerMainView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        registerMainView.alpha = 0;
        registerMainView.frame.origin.y = self.registerMainView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.registerMainView.alpha = 1.0;
            self.registerMainView.frame.origin.y = self.registerMainView.frame.origin.y - 50
        })
    }
    
    func requestRegistration() {
        self.showSpinner(onView: self.view)
        httpRequest(data: [
                "action": "REGISTER".toBase64(),
                "name": nameTextfield.text!.toBase64(),
                "email": emailTextfield.text!.toBase64(),
                "phone_number": phoneTextfield.text!.toBase64(),
                "social_media": socialMediaTextfield.text!.toBase64(),
                "password": passwordTextfield.text!.toBase64(),
                "client_datetime": getTimestamp().toBase64()]){ (returnDict) in
            self.removeSpinner()
            self.processRegistration(data: returnDict!)
        }
    }
    
    func requestEmailConfirmation(emailCode: String) {
        self.showSpinner(onView: self.view)
        httpRequest(data: [
                "action": "EMAIL_CONFIRMATION".toBase64(),
                "email_code": emailCode.toBase64(),
                "email": emailTextfield.text!.toBase64(),
                "password": passwordTextfield.text!.toBase64(),
                "client_datetime": getTimestamp().toBase64()]){ (returnDict) in
            self.removeSpinner()
            self.processEmailConfirmationData(data: returnDict!)
        }
    }
    
    func processRegistration(data: [String:String]) {
        if let returnValue = data["return"] {
            if returnValue.elementsEqual("BAD") {
                self.databaseManager.createData(setting: "LOGGED_IN", value: "", uploadData: false) { returnDictionary in /*CODE HERE*/ }
                DispatchQueue.main.async {
                    self.present(alert(title: data["message"] ?? "Communication Error", message: "", buttonText: "OK"), animated: true)
                }
            } else {
                if let receivedConfirmationCode = data["confirmation_code"] {
                    DispatchQueue.main.async {
                        self.emailTextfield.resignFirstResponder()
                        self.passwordTextfield.resignFirstResponder()
                        
                        self.databaseManager.createData(setting: "EMAIL_CONFIRMATION", value: receivedConfirmationCode.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                        
                        var dynamicAlert = UIAlertController(title: "confirm your email address", message: nil, preferredStyle: .alert)
                        if let returnMessage = data["message"] {
                            dynamicAlert = UIAlertController(title: returnMessage, message: nil, preferredStyle: .alert)
                        }
                        
                        dynamicAlert.addTextField(configurationHandler: { textField in
                            textField.placeholder = "email confirmation code"
                        })

                        dynamicAlert.addAction(UIAlertAction(title: "confirm", style: .default, handler: { action in
                            if let code = dynamicAlert.textFields?.first?.text {
                                if code.count > 0 {
                                    self.matchEmailConfirmationCode(emailCode: code)
                                } else {
                                    DispatchQueue.main.async {
                                        self.present(alert(title: "The code cannot be blank.", message: "", buttonText: "OK"), animated: true)
                                    }
                                }
                            }
                        }))
                        
                        dynamicAlert.addAction(UIAlertAction(title: "cancel", style: .default, handler: { action in
                            self.dismiss(animated: true, completion: nil)
                        }))

                        self.present(dynamicAlert, animated: true)
                    }
                } else {                    DispatchQueue.main.async {
                        self.present(alert(title: data["message"] ?? "Communication Error", message: "", buttonText: "OK"), animated: true)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.present(alert(title: data["message"] ?? "Communication Error", message: "", buttonText: "OK"), animated: true)
            }
        }
    }
    
    func processEmailConfirmationData(data: [String:String]) {
        if let returnValue = data["return"] {
            if returnValue.elementsEqual("BAD") {
                self.databaseManager.createData(setting: "LOGGED_IN", value: "", uploadData: false) { returnDictionary in /*CODE HERE*/ }
                DispatchQueue.main.async {
                    self.present(alert(title: "Error", message: data["message"] ?? "Communication Error", buttonText: "OK"), animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Email confirmed!", message: nil, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "got it", style: .default, handler: { action in
                        self.databaseManager.createData(setting: "LOGGED_IN", value: "YES".encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                        self.databaseManager.createData(setting: "LOGGED_IN_NAME", value: self.nameTextfield.text!.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                        self.databaseManager.createData(setting: "LOGGED_IN_USERNAME", value: self.emailTextfield.text!.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                        self.databaseManager.createData(setting: "LOGGED_IN_PASSWORD", value: self.passwordTextfield.text!.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                        
                        self.delegate?.registerRegister(data: data)
                        self.dismiss(animated: true, completion: nil)
                    }))

                    self.present(alert, animated: true)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.present(alert(title: "Error", message: "Communication Error", buttonText: "OK"), animated: true)
            }
        }
    }
    
    func matchEmailConfirmationCode(emailCode: String){
        let emailConfirmationCode = self.databaseManager.getData(setting: "EMAIL_CONFIRMATION").decrypt()!
        if emailConfirmationCode.elementsEqual(emailCode) {
            requestEmailConfirmation(emailCode: emailCode)
        }
    }
    
    @IBAction func registerButtonTouchUpInside(_ sender: Any) {
        nameTextfield.resignFirstResponder()
        emailTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        
        requestRegistration()
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        nameTextfield.resignFirstResponder()
        emailTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        delegate?.cancelRegister()
        self.dismiss(animated: true, completion: nil)
    }
}
