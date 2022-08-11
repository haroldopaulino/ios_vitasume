//
//  WelcomeViewController.swift
//  iResume
//
//  Created by Harold on 6/14/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, ForgotPasswordDelegate, LoginDelegate, RegisterDelegate {
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var signInEmailTextfield: UITextField!
    @IBOutlet weak var signInPasswordTextfield: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var checkboxImage: UIImageView!
    @IBOutlet weak var saveUserPasswordLabel: UILabel!
    
    var delegate: WelcomeDelegate?
    let databaseManager = DatabaseManager()
    var saveUserPassword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonsStyle()
        initializeData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        setupPlaceHolders()
        setupSaveUserPassword()
        initializeCheckboxImage()
        animateView()
        self.removeSpinner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func initializeData() {
        if databaseManager.getData(setting: "FIRST_APP_EXECUTION").elementsEqual("") {
            databaseManager.createData(setting: "PURCHASE_STATUS", value: "NO", uploadData: true) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "APP_INSTALL_TIMESTAMP", value: getTimestamp(), uploadData: true) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "EMAIL", value: "your_email@here.com", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "FIRST_APP_EXECUTION", value: "NO", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
                
            databaseManager.createData(setting: "NAME", value: "YOUR NAME HERE", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "PHONE_NUMBER", value: "(123) 456-7890", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "SOCIAL_MEDIA", value: "https://www.linkedin.com/in/you", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "SUMMARY", value: "Your summary here", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "STRENGTHS", value: "Your strengths here", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "PROFESSIONAL_EXPERIENCE", value: "Your professional experience here", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "OTHER_RELEVANT_EXPERIENCE", value: "Your other relevant experience here", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "EDUCATION", value: "Your education here", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            DispatchQueue.main.async {
                //self.present(alert(title: "Welcome to VitaSume!\n\nThe top left corner menu has all you need.", message: "", buttonText: "OK"), animated: true)
                //self.openWelcome();
            }
        }
        DispatchQueue.main.async {
            //self.present(alert(title: "Welcome to VitaSume!\n\nThe top left corner menu has all you need.", message: "", buttonText: "OK"), animated: true)
            //self.openWelcome();
        }
        /*if databaseManager.getData(setting: "FIRST_APP_EXECUTION").elementsEqual("") {
            databaseManager.createData(setting: "EMAIL", value: "russ2003@gmail.com", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "FIRST_APP_EXECUTION", value: "NO", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
                
            databaseManager.createData(setting: "NAME", value: "RUSS MYERS", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "PHONE_NUMBER", value: "8013764791", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "SOCIAL_MEDIA", value: "https://www.linkedin.com/in/1russmyers", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "SUMMARY", value: "MANAGING DIRECTOR and GENERAL MANAGER\n\nManaging Director and General Manager with a demonstrated history of product development and customer satisfaction.\n\nSkilled in continuous improvement, leadership, business process improvement, 5S, and Six Sigma.\n\nA strong business development professional with practice in solving customer problems in unique markets from jewelry to construction.\n\nA process-driven leader with a foundation in Mechanical Engineering. Skilled at problem-solving with an ability to evaluate new industries, build teams with intentional culture, drive customer-centric results, and identify priorities to balance P&L responsibility with limited resources.", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "STRENGTHS", value: "* Recognize and define customer concerns.\n\n* Engage customers in support of strategy.\n\n* Interface with key stakeholders and help them succeed.\n\n* Understand value to prioritize needs.\n\n* Align strategy and execution to the delivery of value to customers.\n\n* Establish and communicate a clear vision of success.", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "PROFESSIONAL_EXPERIENCE", value: "Apergy - US Synthetic Corporation, Orem, UT September 1997 – April 2020\n(Comprises 500- 1000 employees serving the oil and gas industry with synthetic diamond).\n\nGeneral Manager\nMining and Construction Division (April 2008 – April 2020)\n\nThis division was acquired as part of a downstream business development strategy to reach end users. Starting with a small team of two employees, it quickly grew to $10M in revenue.\n\nDefining vision and culture for the team through product and project management was very rewarding. Priorities and Kanban were critical in balancing scope with P&L responsibilities.\n\nUnderstanding the customer need beyond apparent requests drove customer satisfaction.\n\nRelocated to St Louis to acquire and manage downstream business:\n\n* Created company structure and organization.\n* Generated 53% revenue growth over seven years.\n* Increased profitability by 65%.\n* Evaluated CapEx investment and ROI strategy to create internal manufacturing.\n* Increased inventory turns by 600%.\n* Reduced inventory value by 83%.\n* Created customer-centric strategy that built brand confidence.\n* Developed sales and marketing strategy creating strong industry brand recognition.\nFormed partnerships through customer, pricing, and consignment contracts.\nCreated a strong intellectual property position resulting in 8 patents and several disclosures.\n* General Manager, Suncrest HPHT Process (June 2003 – March 2008)\nThis internal business was grown organically through the development of a high pressure high temperature process to improve the color of natural diamond in the wholesale diamond industry. Customer obsessed support and market saturation were key strategies in developing the business. Face to face customer interaction was critical to developing trust and relationships.\n\n* Generated revenue growth from inception to $1.5M in sales.\n* Transformed a unique business model into a corporate structure.\n* Traveled extensively acquiring customers building trust in the product.\n* Chosen to speak on several industry panels and at educational institutions: Gemological Institute of America, Gemological Association of Hong Kong, American Gem Trade Association, International Colored Gemstone Association.\n* Gained new customers through distinct market strategies and support material.\n* Developed incremental revenue stream with new product offerings creating market disruption.\n* Provided analysis of new market that determined ROI and CapEx requirements.", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "OTHER_RELEVANT_EXPERIENCE", value: "Customer Account Manager\nWorked closely with customer accounts to engineer new product offerings that would make their businesses successful. Used 5-why methodology to understand need and define customer specifications/deliverables.\n\nResearch and Development Manager\nUsed statistical and analytical methods to develop new products for industry use. Designed product specification and process integration for product launches.", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
            
            databaseManager.createData(setting: "EDUCATION", value: "Master of Business Administration\nOperational Excellence – Utah State University, 2016\n\nBachelor of Science - Mechanical Engineering\nBrigham Young University", uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
        }*/
    }
    
    func parseOutputResponse(inputResponse: [String:String]) {
        for (key, value) in inputResponse {
            if key.elementsEqual("result") {
                //showAlert(title: "", message: value)
            }
        }
    }
    
    func buttonsStyle() {
        signInButton.layer.cornerRadius = 5
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.gray.cgColor
        
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor.gray.cgColor
    }
    
    func setupView() {
        mainView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func setupPlaceHolders() {
        signInEmailTextfield.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:210.0/255.0, green:210.0/255.0, blue:210.0/255.0, alpha:1.0)])
        signInPasswordTextfield.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:210.0/255.0, green:210.0/255.0, blue:210.0/255.0, alpha:1.0)])

    }
    
    func setupSaveUserPassword() {
        let checkboxImageTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.toggleCheckboxImage))
        checkboxImageTapGetsure.numberOfTapsRequired = 1
        checkboxImage.addGestureRecognizer(checkboxImageTapGetsure)
        
        let saveUserPasswordLabelTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.toggleCheckboxImage))
        saveUserPasswordLabelTapGetsure.numberOfTapsRequired = 1
        saveUserPasswordLabel.addGestureRecognizer(saveUserPasswordLabelTapGetsure)
        
        checkboxImage.isUserInteractionEnabled = true
        saveUserPasswordLabel.isUserInteractionEnabled = true
    }
    
    func initializeCheckboxImage() {
        let loggedInUsernameIsSet = self.databaseManager.getData(setting: "LOGGED_IN_USERNAME").decrypt() == "" ? false : true
        let loggedInPasswordIsSet = self.databaseManager.getData(setting: "LOGGED_IN_PASSWORD").decrypt() == "" ? false : true
        saveUserPassword = self.databaseManager.getData(setting: "SAVE_USER_AND_PASSWORD") == "YES" ? true : false
        if saveUserPassword &&
           loggedInUsernameIsSet &&
           loggedInPasswordIsSet {
            DispatchQueue.main.async {
                self.loadLocalCredentials()
                self.checkboxImage.image = UIImage(named: "checkbox_checked")
            }
        } else {
            DispatchQueue.main.async {
                self.checkboxImage.image = UIImage(named: "checkbox_unchecked")
            }
        }
    }
    
    @objc func toggleCheckboxImage() {
        saveUserPassword = !saveUserPassword
        if saveUserPassword {
            DispatchQueue.main.async {
                self.databaseManager.createLocalData(setting: "SAVE_USER_AND_PASSWORD", value: "YES")
                self.checkboxImage.image = UIImage(named: "checkbox_checked")
            }
        } else {
            DispatchQueue.main.async {
                self.databaseManager.createLocalData(setting: "SAVE_USER_AND_PASSWORD", value: "NO")
                self.checkboxImage.image = UIImage(named: "checkbox_unchecked")
            }
        }
    }
    
    func loadLocalCredentials() {
        signInEmailTextfield.text = self.databaseManager.getData(setting: "LOGGED_IN_USERNAME").decrypt()
        signInPasswordTextfield.text = self.databaseManager.getData(setting: "LOGGED_IN_PASSWORD").decrypt()
    }
    
    func requestLogin() {
        let loggedInUsernameIsSet = self.signInEmailTextfield.text! == "" ? false : true
        let loggedInPasswordIsSet = self.signInPasswordTextfield.text! == "" ? false : true
        if loggedInUsernameIsSet &&
           loggedInPasswordIsSet {
            self.showSpinner(onView: self.view)
            httpRequest(data: [
                "action": "LOGIN".toBase64(),
                "client_datetime": getTimestamp().toBase64(),
                "email": (signInEmailTextfield.text!).toBase64(),
                "password": (signInPasswordTextfield.text!).toBase64()]){ (returnDict) in
                    self.processLoginData(data: returnDict!)
            }
        }
    }
    
    func processLoginData(data: [String:String]) {
        if let returnValue = data["return"] {
            if returnValue.elementsEqual("BAD") {
                DispatchQueue.main.async {
                    self.databaseManager.createData(setting: "LOGGED_IN", value: "NO".encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    self.databaseManager.createData(setting: "LOADED_EMAIL", value: "", uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    self.databaseManager.createData(setting: "LOGGED_IN_PASSWORD", value: "", uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    
                    self.present(alert(title: "Error", message: data["message"] ?? "Communication Error", buttonText: "OK"), animated: true)
                    self.loadLocalCredentials()
                }
            } else {
                DispatchQueue.main.async {
                    self.databaseManager.createData(setting: "LOGGED_IN", value: "YES".encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    self.databaseManager.createData(setting: "LOADED_EMAIL", value: self.signInEmailTextfield.text!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    self.databaseManager.createData(setting: "LOGGED_IN_USERNAME", value: self.signInEmailTextfield.text!.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    self.databaseManager.createData(setting: "LOGGED_IN_PASSWORD", value: self.signInPasswordTextfield.text!.encrypt()!, uploadData: false) { returnDictionary in /*CODE HERE*/ }
                    
                    self.signInEmailTextfield.resignFirstResponder()
                    self.signInPasswordTextfield.resignFirstResponder()
                    
                    self.loadData(data: data)
                    
                    self.openMainStoryboard()
                }
            }
        }
        self.removeSpinner()
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
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "Main") as! MainViewController
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
    
    func openForgotPassword() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "ForgotPassword", bundle: nil)
        let forgotPasswordViewController = storyBoard.instantiateViewController(withIdentifier: "ForgotPassword") as! ForgotPasswordViewController
        forgotPasswordViewController.delegate = self
        self.present(forgotPasswordViewController, animated: true, completion: nil)
    }
    
    func openRegistration() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Register", bundle: nil)
        let registerViewController = storyBoard.instantiateViewController(withIdentifier: "Register") as! RegisterViewController
        registerViewController.delegate = self
        self.present(registerViewController, animated: true, completion: nil)
    }
    
    func animateView() {
        mainView.alpha = 0;
        self.mainView.frame.origin.y = self.mainView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.mainView.alpha = 1.0;
            self.mainView.frame.origin.y = self.mainView.frame.origin.y - 50
        })
    }
    
    func loginWithLocalUserCredentials() {
        saveUserPassword = self.databaseManager.getData(setting: "SAVE_USER_AND_PASSWORD") == "YES" ? true : false
        if saveUserPassword {
            signInEmailTextfield.text = self.databaseManager.getData(setting: "LOGGED_IN_USERNAME").decrypt()
            signInPasswordTextfield.text = self.databaseManager.getData(setting: "LOGGED_IN_PASSWORD").decrypt()
            requestLogin()
        }
    }
    
    @IBAction func singInButtonTouchUpInside(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        requestLogin()
    }
    
    @IBAction func registerButtonTouchUpInside(_ sender: Any) {
        openRegistration()
    }
    
    @IBAction func forgotPasswordTouchUpInside(_ sender: Any) {
        openForgotPassword()
    }
    
    //FORGOT PASSWORD DELEGATE - begin
    func finishForgotPassword(email: String, code: String, newPassword: String) {
        loginWithLocalUserCredentials()
    }
    
    func cancelForgotPassword() {
        
    }
    //FORGOT PASSWORD DELEGATE - end
    
    //LOGIN DELEGATE - begin
    func loginLogin(email: String, password: String, data: [String : String]) {
        self.removeSpinner()
    }
    
    func cancelLogin() {
        self.removeSpinner()
    }
    //LOGIN DELEGATE - end
    
    //REGISTER DELEGATE - begin
    func registerRegister(data: [String : String]) {
        loginWithLocalUserCredentials()
    }
    
    func cancelRegister() {
        
    }
    //REGISTER DELEGATE - end
}
