//
//  ManageViewController.swift
//  iResume
//
//  Created by Harold on 6/13/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet var manageMainView: UIView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var delegate: LoginDelegate?
    let databaseManager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.becomeFirstResponder()
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
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.black.cgColor
        
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func setupView() {
        manageMainView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        manageMainView.alpha = 0;
        self.manageMainView.frame.origin.y = self.manageMainView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.manageMainView.alpha = 1.0;
            self.manageMainView.frame.origin.y = self.manageMainView.frame.origin.y - 50
        })
    }
    
    func requestLogin() {
        httpRequest(data: [
            "action": "LOGIN".toBase64(),
            "client_datetime": getTimestamp().toBase64(),
            "email": (emailTextfield.text!).toBase64(),
            "password": (passwordTextfield.text!).toBase64()]){ (returnDict) in
                self.processLoginData(data: returnDict!)
        }
    }
    
    func processLoginData(data: [String:String]) {
        DispatchQueue.main.async {
            self.removeSpinner()
        }
        if let returnValue = data["return"] {
            if returnValue.elementsEqual("BAD") {
                self.databaseManager.createData(setting: "LOGGED_IN", value: "NO".encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                DispatchQueue.main.async {
                    self.present(alert(title: "Error", message: data["message"] ?? "Communication Error", buttonText: "OK"), animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.emailTextfield.resignFirstResponder()
                    self.passwordTextfield.resignFirstResponder()
                    
                    self.databaseManager.createData(setting: "LOGGED_IN", value: "YES".encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    self.databaseManager.createData(setting: "LOGGED_IN_USERNAME", value: self.emailTextfield.text!.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    self.databaseManager.createData(setting: "LOGGED_IN_PASSWORD", value: self.passwordTextfield.text!.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    
                    self.loadData(data: data)
                    //self.openMainStoryboard()
                    
                    /*let alert = UIAlertController(title: data["message"], message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "got it", style: .default, handler: { action in
                        self.removeSpinner()
                        self.delegate?.loginLogin(email: self.emailTextfield.text!, password: self.passwordTextfield.text!, data: data)
                        self.dismiss(animated: true, completion: nil)
                    }))

                    self.present(alert, animated: true)*/
                }
            }
            self.delegate?.loginLogin(email: self.emailTextfield.text!, password: self.passwordTextfield.text!, data: data)
        } else {
            self.delegate?.cancelLogin()
        }
    }
    
    func loadData(data: [String:String]) {
        databaseManager.deleteData(setting: "SUMMARY")
        databaseManager.deleteData(setting: "STRENGTHS")
        databaseManager.deleteData(setting: "PROFESSIONAL_EXPERIENCE")
        databaseManager.deleteData(setting: "OTHER_RELEVANT_EXPERIENCE")
        databaseManager.deleteData(setting: "EDUCATION")
        if let email = data["email"] {
            self.databaseManager.updateData(setting: "EMAIL", value: email, uploadData: false) { returnDictionary in
                //self.parseOutputResponse(inputResponse: returnDictionary!)
            }
        }
        
        do {
            if data.count > 0 {
                if let fieldCount = Int(data["fields_count"]!) {
                    for i in 1...fieldCount {
                        let fieldName = data["fieldname_" + String(i)]
                        let fieldValue = data["fieldvalue_" + String(i)]
                        self.databaseManager.updateData(setting: fieldName!, value: fieldValue!, uploadData: false) { returnDictionary in
                            //self.parseOutputResponse(inputResponse: returnDictionary!)
                        }
                    }
                }
            }
        }
    }
    
    func openMainStoryboard() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "Main") as! HomeViewController
        //registerViewController.delegate = self
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonTouchUpInside(_ sender: Any) {
        emailTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        
        self.showSpinner(onView: self.view)
        requestLogin()
        //delegate?.loginManage(email: emailTextfield.text!, password: passwordTextfield.text!)
        //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelcancelButtonTouchUpInside(_ sender: Any) {
        emailTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        delegate?.cancelLogin()
        self.dismiss(animated: true, completion: nil)
    }
}
