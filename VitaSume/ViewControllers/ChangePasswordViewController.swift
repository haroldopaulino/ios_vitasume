//
//  ChangePasswordViewController.swift
//  iResume
//
//  Created by Harold on 6/12/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    
    @IBOutlet var changePasswordMainView: UIView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var oldPasswordTextfield: UITextField!
    @IBOutlet weak var newPasswordTextfield: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var delegate: ChangePasswordDelegate?
    let databaseManager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.white.cgColor
        
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.white.cgColor
    }
    
    func setupView() {
        changePasswordMainView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        if (databaseManager.getData(setting: "LOGGED_IN").decrypt()?.elementsEqual("YES"))! {
            emailTextfield.text = databaseManager.getData(setting: "LOGGED_IN_USERNAME").decrypt()
            oldPasswordTextfield.becomeFirstResponder()
        } else {
            emailTextfield.becomeFirstResponder()
        }
    }
    
    func animateView() {
        changePasswordMainView.alpha = 0;
        changePasswordMainView.frame.origin.y = self.changePasswordMainView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.changePasswordMainView.alpha = 1.0;
            self.changePasswordMainView.frame.origin.y = self.changePasswordMainView.frame.origin.y - 50
        })
    }
    
    func processPasswordChangeData(data: [String:String]) {
        if let returnValue = data["return"] {
            if returnValue.elementsEqual("BAD") {
                DispatchQueue.main.async {
                    self.present(alert(title: "Error", message: data["message"] ?? "Communication Error", buttonText: "OK"), animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.databaseManager.createData(setting: "LOGGED_IN_PASSWORD", value: self.newPasswordTextfield.text!.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    
                    self.emailTextfield.resignFirstResponder()
                    self.oldPasswordTextfield.resignFirstResponder()
                    self.newPasswordTextfield.resignFirstResponder()
                    
                    let alert = UIAlertController(title: data["message"], message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "got it", style: .default, handler: { action in
                        self.delegate?.saveChangePassword(email: self.emailTextfield.text!, oldPassword: self.oldPasswordTextfield.text!, newPassword: self.newPasswordTextfield.text!)
                        self.dismiss(animated: true, completion: nil)
                    }))

                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func requestChangePassword() {
        self.showSpinner(onView: self.view)
        httpRequest(data: [
                "action": "CHANGE_PASSWORD".toBase64(),
                "client_datetime": getTimestamp().toBase64(),
                "email": (emailTextfield.text!).toBase64(),
                "old_password": (oldPasswordTextfield.text!).toBase64(),
                "new_password": (newPasswordTextfield.text!).toBase64()]){ (returnDict) in
            self.removeSpinner()
            self.processPasswordChangeData(data: returnDict!)
        }
    }
    
    @IBAction func saveButtonTouchUpInside(_ sender: Any) {
        if (oldPasswordTextfield.text?.elementsEqual(newPasswordTextfield.text!))! {
            DispatchQueue.main.async {
                self.present(alert(title: "Error", message: "Old and new passwords cannot be equal.", buttonText: "OK"), animated: true)
            }
        } else if ((oldPasswordTextfield.text?.elementsEqual(""))! ||
            (newPasswordTextfield.text?.elementsEqual(""))!) {
            self.present(alert(title: "Error", message: "Old and new passwords cannot be blank.", buttonText: "OK"), animated: true)
        } else {
            requestChangePassword()
        }
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        emailTextfield.resignFirstResponder()
        oldPasswordTextfield.resignFirstResponder()
        newPasswordTextfield.resignFirstResponder()
        delegate?.cancelChangePassword()
        self.dismiss(animated: true, completion: nil)
    }
    
}
