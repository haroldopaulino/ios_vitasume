//
//  HomeViewController.swift
//  RussMyers
//
//  Created by Harold on 4/15/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit


class HomeViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LoginDelegate, LoadDelegate, ChangePasswordDelegate, ActivationDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var mainImageview: UIImageView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBOutlet weak var telephoneView: UIView!
    @IBOutlet weak var telephoneImage: UIImageView!
    @IBOutlet weak var telephoneTextfield: UITextField!
    @IBOutlet weak var telephoneButton: UIButton!
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailImage: UIImageView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var socialMediaTextfield: UITextField!
    @IBOutlet weak var socialMediaView: UIView!
    @IBOutlet weak var socialMediaImage: UIImageView!
    @IBOutlet weak var socialMediaButton: UIButton!
    
    @IBOutlet weak var mainMenuBackgroundImage: UIImageView!
    @IBOutlet weak var mainMenuImageView: UIImageView!
    @IBOutlet weak var mainMenuButton: UIButton!
    
    @IBOutlet weak var loginLogoutImageview: UIImageView!
    @IBOutlet weak var loginLogoutButton: UIButton!
    
    @IBOutlet weak var loadCodeEmailImageview: UIImageView!
    @IBOutlet weak var loadCodeEmailButton: UIButton!
    
    @IBOutlet weak var changePasswordImageview: UIImageView!
    @IBOutlet weak var changePasswordButton: UIButton!

    @IBOutlet weak var helpImageview: UIImageView!
    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var activationImageview: UIImageView!
    @IBOutlet weak var activationButton: UIButton!
    
    @IBOutlet weak var fieldsTransparencyImage: UIImageView!
    
    
    let databaseManager = DatabaseManager()
    var alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
    var openMenu = true
    var mode = "load"
    var productIDs = [String](arrayLiteral: "resume_management_unlock")
    var inAppProducts = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainMenu()
        loadLocalDataToObjects(uploadImageIfExists: true)
        loadPurchaseData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func loadPurchaseData() {
        PKIAPHandler.shared.setProductIds(ids: self.productIDs)
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products) in
            self!.inAppProducts = products
        }
        PKIAPHandler.shared.restorePurchase()
    }
    
    func loadLocalDataToObjects(uploadImageIfExists: Bool) {
        DispatchQueue.main.async {
            self.setupMainImageview()
            self.setupName()
            self.setupTelephone()
            self.setupEmail()
            self.setupSocialMedia()
            
            self.databaseManager.createLocalData(setting: "MAIN_IMAGE_WAS_DOWNLOADED", value: "NO")
            checkIfImageExistsAndDownload(imageName: mainImageName, imageView: self.mainImageview) { returnMessage in
                if (returnMessage?.elementsEqual("BAD"))! {
                    DispatchQueue.main.async {
                        self.mainImageview.image = UIImage(named: "background2")
                    }
                }
            }
        }
    }
    
    func toggleMainMenu(forceHideMenu: Bool) {
        if isUserLoggedIn() {
            loginLogoutButton.setTitle("logout", for: UIControl.State.normal)
        } else {
            loginLogoutButton.setTitle("login", for: UIControl.State.normal)
        }
        openMenu = !openMenu
        if (openMenu && !forceHideMenu) {
            mainMenuButton.setBackgroundImage(UIImage(named: "menu_vertical_bars"), for: UIControl.State.normal)
            mainMenuBackgroundImage.isHidden = false
            loginLogoutImageview.isHidden    = false
            loginLogoutButton.isHidden       = false
            loadCodeEmailImageview.isHidden  = false
            loadCodeEmailButton.isHidden     = false
            changePasswordImageview.isHidden = false
            changePasswordButton.isHidden    = false
            helpImageview.isHidden           = false
            helpButton.isHidden              = false
            activationImageview.isHidden     = false
            activationButton.isHidden        = false
        } else {
            mainMenuButton.setBackgroundImage(UIImage(named: "menu_horizontal_bars"), for: UIControl.State.normal)
            mainMenuBackgroundImage.isHidden = true
            loginLogoutImageview.isHidden    = true
            loginLogoutButton.isHidden       = true
            loadCodeEmailImageview.isHidden  = true
            loadCodeEmailButton.isHidden     = true
            changePasswordImageview.isHidden = true
            changePasswordButton.isHidden    = true
            helpImageview.isHidden           = true
            helpButton.isHidden              = true
            activationImageview.isHidden     = true
            activationButton.isHidden        = true
        }
    }
    
    @objc func hideMainMenu() {
        toggleMainMenu(forceHideMenu: true)
    }
    
    func setupMainImageview() {
        loadImageFromDocumentDirectory(imageName: "main_image.jpeg", imageView: mainImageview)
        
        let mainImageviewTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.hideMainMenu))
        mainImageviewTapGetsure.numberOfTapsRequired = 1
        mainImageview.addGestureRecognizer(mainImageviewTapGetsure)
        
        let mainImageviewLongPressTapGetsure = UILongPressGestureRecognizer(target: self, action: #selector(editMainImage))
        mainImageviewLongPressTapGetsure.minimumPressDuration = 1.5
        mainImageview.addGestureRecognizer(mainImageviewLongPressTapGetsure)
        
        mainImageview.isUserInteractionEnabled = true
    }
    
    func setupMainMenu() {
        toggleMainMenu(forceHideMenu: false)
        
        loginLogoutImageview.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
        loginLogoutImageview.layer.masksToBounds = true
        loginLogoutImageview.contentMode = .scaleToFill
        loginLogoutImageview.layer.borderWidth = 2
        
        loadCodeEmailImageview.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
        loadCodeEmailImageview.layer.masksToBounds = true
        loadCodeEmailImageview.contentMode = .scaleToFill
        loadCodeEmailImageview.layer.borderWidth = 2
        
        changePasswordImageview.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
        changePasswordImageview.layer.masksToBounds = true
        changePasswordImageview.contentMode = .scaleToFill
        changePasswordImageview.layer.borderWidth = 2
        
        helpImageview.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
        helpImageview.layer.masksToBounds = true
        helpImageview.contentMode = .scaleToFill
        helpImageview.layer.borderWidth = 2
        
        activationImageview.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
        activationImageview.layer.masksToBounds = true
        activationImageview.contentMode = .scaleToFill
        activationImageview.layer.borderWidth = 2
    }
    
    func setupName() {
        nameButton.setTitle(databaseManager.getData(setting: "NAME"), for: UIControl.State.normal)
        nameTextfield.text = databaseManager.getData(setting: "NAME")
        
        nameTextfield.delegate = self
        nameTextfield.isHidden = true
        
        let nameTextfieldTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.hideMainMenu))
        nameTextfieldTapGetsure.numberOfTapsRequired = 1
        nameButton.addGestureRecognizer(nameTextfieldTapGetsure)
        
        let nameTextfieldLongPressTapGetsure = UILongPressGestureRecognizer(target: self, action: #selector(editName))
        nameTextfieldLongPressTapGetsure.minimumPressDuration = 1.5
        nameButton.addGestureRecognizer(nameTextfieldLongPressTapGetsure)
        
        nameButton.isUserInteractionEnabled = true
        nameTextfield.isUserInteractionEnabled = true
    }
    
    func setupTelephone() {
        telephoneButton.setTitle(databaseManager.getData(setting: "PHONE_NUMBER"), for: UIControl.State.normal)
        telephoneTextfield.text = databaseManager.getData(setting: "PHONE_NUMBER")
        
        telephoneTextfield.delegate = self
        telephoneTextfield.isHidden = true
        
        let telephoneImageTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.callPhone))
        telephoneImageTapGetsure.numberOfTapsRequired = 1
        telephoneImage.addGestureRecognizer(telephoneImageTapGetsure)
        
        let telephoneTextfieldTapGetsure = UITapGestureRecognizer(target: self, action: #selector(callPhone))
        telephoneTextfieldTapGetsure.numberOfTapsRequired = 1
        telephoneButton.addGestureRecognizer(telephoneTextfieldTapGetsure)
        
        let telephoneTextfieldLongPressTapGetsure = UILongPressGestureRecognizer(target: self, action: #selector(editPhone))
        telephoneTextfieldLongPressTapGetsure.minimumPressDuration = 1.5
        telephoneButton.addGestureRecognizer(telephoneTextfieldLongPressTapGetsure)
        
        telephoneImage.isUserInteractionEnabled = true
        telephoneButton.isUserInteractionEnabled = true
        telephoneTextfield.isUserInteractionEnabled = true
    }
    
    func setupEmail() {
        emailButton.setTitle(databaseManager.getData(setting: "EMAIL"), for: UIControl.State.normal)
        emailTextfield.text = databaseManager.getData(setting: "EMAIL")
        
        emailTextfield.delegate = self
        emailTextfield.isHidden = true
        
        let emailImageTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.sendEmail))
        emailImageTapGetsure.numberOfTapsRequired = 1
        emailImage.addGestureRecognizer(emailImageTapGetsure)
        
        let emailTextfieldTapGetsure = UITapGestureRecognizer(target: self, action: #selector(sendEmail))
        emailTextfieldTapGetsure.numberOfTapsRequired = 1
        emailButton.addGestureRecognizer(emailTextfieldTapGetsure)
        
        let emailTextfieldLongPressTapGetsure = UILongPressGestureRecognizer(target: self, action: #selector(editEmail))
        emailTextfieldLongPressTapGetsure.minimumPressDuration = 1.5
        emailButton.addGestureRecognizer(emailTextfieldLongPressTapGetsure)
        
        emailImage.isUserInteractionEnabled = true
        emailButton.isUserInteractionEnabled = true
        emailTextfield.isUserInteractionEnabled = true
    }
    
    func setupSocialMedia() {
        socialMediaButton.setTitle(databaseManager.getData(setting: "SOCIAL_MEDIA"), for: UIControl.State.normal)
        socialMediaTextfield.text = databaseManager.getData(setting: "SOCIAL_MEDIA")
        
        socialMediaTextfield.delegate = self
        socialMediaTextfield.isHidden = true
        
        let socialMediaImageTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.openSocialMedia))
        socialMediaImageTapGetsure.numberOfTapsRequired = 1
        socialMediaImage.addGestureRecognizer(socialMediaImageTapGetsure)
        
        let socialMediaTextfieldTapGetsure = UITapGestureRecognizer(target: self, action: #selector(openSocialMedia))
        socialMediaTextfieldTapGetsure.numberOfTapsRequired = 1
        socialMediaButton.addGestureRecognizer(socialMediaTextfieldTapGetsure)
        
        let socialMediaTextfieldLongPressTapGetsure = UILongPressGestureRecognizer(target: self, action: #selector(editSocialMedia))
        socialMediaTextfieldLongPressTapGetsure.minimumPressDuration = 1.5
        socialMediaButton.addGestureRecognizer(socialMediaTextfieldLongPressTapGetsure)
        
        socialMediaImage.isUserInteractionEnabled = true
        socialMediaButton.isUserInteractionEnabled = true
        socialMediaTextfield.isUserInteractionEnabled = true
    }
    
    func repositionViewForOnScreenKeyboard(keyboardOn: Bool) {
        if let myConstraint = mainView.findConstraintByIdentifierName(identifier: "fieldsTransparencyImageVerticalCenterConstraint") {
            if keyboardOn {
                myConstraint.constant = -80
            } else {
                myConstraint.constant = 100
            }
         }
    }
    
    func areLoggedInEmailAndLoadedEmailTheSame() -> Bool {
        return self.databaseManager.getData(setting: "LOADED_EMAIL") == self.databaseManager.getData(setting: "LOGGED_IN_USERNAME").decrypt()
    }
    
    @objc func callPhone() {
        hideMainMenu()
        var phoneNumber = databaseManager.getData(setting: "PHONE_NUMBER").filter("0123456789.".contains)
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {

            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                     application.openURL(phoneCallURL as URL)

                }
            }
        } else {
            self.alertController = UIAlertController(title: "Error", message:
                "Could not open the Phone app.", preferredStyle: .alert)
            self.alertController.addAction(UIAlertAction(title: "OK", style: .default))

            self.present(self.alertController, animated: true, completion: nil)
        }
    }
    
    @objc func editMainImage() {
        hideMainMenu()
        if areLoggedInEmailAndLoadedEmailTheSame() {
            let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))

            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
                self.openGallery()
            }))

            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
        } else {
            //displayLoadedEmailDifferentThanLoggedEmailAlert()
        }
    }
    
    func openCamera() {
        hideMainMenu()
        if areLoggedInEmailAndLoadedEmailTheSame() {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            else
            {
                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            //displayLoadedEmailDifferentThanLoggedEmailAlert()
        }
    }
    
    func openGallery() {
        hideMainMenu()
        if areLoggedInEmailAndLoadedEmailTheSame() {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            else
            {
                let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            //displayLoadedEmailDifferentThanLoggedEmailAlert()
        }
    }
    
    //MARK:-- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let capturedImage = info[.originalImage] as? UIImage {
            mainImageview.image = capturedImage
            //mainImageview.contentMode = .scaleToFill
            saveImageToDocumentDirectory(imageData: capturedImage, imageName: "main_image.jpeg", upload: true)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func displayAlertAndOpenManageResume() {
        let alertController = UIAlertController(title: "Resume Management", message:
            "You must login to manage this resume.\nGo to Menu and choose 'manage resume'.", preferredStyle: .alert)
        let manageResumeAlertButton = UIAlertAction(title: "manage resume", style: UIAlertAction.Style.default, handler: { action in
            self.openManageResume()
        })
        alertController.addAction(manageResumeAlertButton)
        alertController.addAction(UIAlertAction(title: "cancel", style: .destructive))

        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayLoadedEmailDifferentThanLoggedEmailAlert() {
        let loadedEmail = self.databaseManager.getData(setting: "LOADED_EMAIL")
        let loggedEmail = self.databaseManager.getData(setting: "LOGGED_IN_USERNAME").decrypt()!
        if loadedEmail != loggedEmail {
            let alertController = UIAlertController(title: "Resume Management", message:
                "You are logged in as \(loggedEmail), so you cannot manage the resume belonging to \(loadedEmail).\nPlease login as \(loadedEmail), so you may manage this resume.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "ok", style: .destructive))

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func openManageResume() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        loginViewController.delegate = self
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    @objc func editName() {
        if areLoggedInEmailAndLoadedEmailTheSame() {
            if isUserLoggedIn() && isAppActivated() {
                nameTextfield.text = databaseManager.getData(setting: "NAME")
                nameButton.isHidden = true
                nameTextfield.isHidden = false
                repositionViewForOnScreenKeyboard(keyboardOn: true)
                nameTextfield.becomeFirstResponder()
            } else {
                displayAlertAndOpenManageResume()
            }
        } else {
            //displayLoadedEmailDifferentThanLoggedEmailAlert()
        }
    }
    
    @objc func editPhone() {
        if areLoggedInEmailAndLoadedEmailTheSame() {
            if isUserLoggedIn() && isAppActivated() {
                telephoneTextfield.text = databaseManager.getData(setting: "PHONE_NUMBER")
                telephoneButton.isHidden = true
                telephoneTextfield.isHidden = false
                repositionViewForOnScreenKeyboard(keyboardOn: true)
                telephoneTextfield.becomeFirstResponder()
            } else {
                displayAlertAndOpenManageResume()
            }
        } else {
            //displayLoadedEmailDifferentThanLoggedEmailAlert()
        }
    }
    
    @objc func editEmail() {
        if areLoggedInEmailAndLoadedEmailTheSame() {
            if isUserLoggedIn() && isAppActivated() {
                telephoneTextfield.text = databaseManager.getData(setting: "EMAIL")
                emailButton.isHidden = true
                emailTextfield.isHidden = false
                repositionViewForOnScreenKeyboard(keyboardOn: true)
                emailTextfield.becomeFirstResponder()
            } else {
                displayAlertAndOpenManageResume()
            }
        } else {
            //displayLoadedEmailDifferentThanLoggedEmailAlert()
        }
    }
    
    @objc func editSocialMedia() {
        if areLoggedInEmailAndLoadedEmailTheSame() {
            if isUserLoggedIn() && isAppActivated() {
                telephoneTextfield.text = databaseManager.getData(setting: "SOCIAL_MEDIA")
                socialMediaButton.isHidden = true
                socialMediaTextfield.isHidden = false
                repositionViewForOnScreenKeyboard(keyboardOn: true)
                socialMediaTextfield.becomeFirstResponder()
            } else {
                displayAlertAndOpenManageResume()
            }
        } else {
            //displayLoadedEmailDifferentThanLoggedEmailAlert()
        }
    }
    
    @objc func saveData() {
        if nameButton.isHidden {
            nameButton.titleLabel?.text = nameTextfield.text
            nameButton.setTitle(nameTextfield.text, for: UIControl.State.normal)

            nameButton.isHidden = false
            nameTextfield.isHidden = true
            databaseManager.updateData(setting: "NAME", value: nameTextfield.text ?? "", uploadData: true) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
        }
        
        if telephoneButton.isHidden {
            telephoneButton.titleLabel?.text = telephoneTextfield.text
            telephoneButton.setTitle(telephoneTextfield.text, for: UIControl.State.normal)
            telephoneButton.isHidden = false
            telephoneTextfield.isHidden = true
            databaseManager.updateData(setting: "PHONE_NUMBER", value: telephoneTextfield.text ?? "", uploadData: true) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
        }
        
        if emailButton.isHidden {
            emailButton.titleLabel?.text = emailTextfield.text
            emailButton.setTitle(emailTextfield.text, for: UIControl.State.normal)
            emailButton.isHidden = false
            emailTextfield.isHidden = true
            databaseManager.updateData(setting: "EMAIL", value: emailTextfield.text ?? "", uploadData: true) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
        }
        
        if socialMediaButton.isHidden {
            var socialMediaUrl = socialMediaTextfield.text ?? ""
            if !socialMediaUrl.isEmpty {
                if !socialMediaUrl.lowercased().hasPrefix("https://") &&
                    !socialMediaUrl.lowercased().hasPrefix("http://") {
                    socialMediaUrl = "https://" + socialMediaUrl
                }
            }
                
            socialMediaButton.titleLabel?.text = socialMediaUrl
            socialMediaButton.setTitle(socialMediaUrl, for: UIControl.State.normal)
            socialMediaButton.isHidden = false
            socialMediaTextfield.isHidden = true
            databaseManager.updateData(setting: "SOCIAL_MEDIA", value: socialMediaUrl, uploadData: true) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
        }
    }
    
    @objc func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
             let mailComposeViewController = MFMailComposeViewController()
             mailComposeViewController.mailComposeDelegate = self
             mailComposeViewController.setToRecipients([databaseManager.getData(setting: "EMAIL")])
             mailComposeViewController.setSubject("Message for " + databaseManager.getData(setting: "NAME"))
             mailComposeViewController.setMessageBody("Hi " + databaseManager.getData(setting: "NAME") + ", I have an exciting job opportunity for you! YOUR MESSAGE HERE", isHTML: false)
         
             present(mailComposeViewController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Cannot Send Emails", message:
                "Please add an email account to your device, then you can email me!\n\nYou can always call me or contact me through my Social Media account.", preferredStyle: .alert)
            let callPhoneFunction = UIAlertAction(title: "Call " + databaseManager.getData(setting: "NAME"), style: UIAlertAction.Style.default, handler: { action in
                self.callPhone()
            })
            let socialMediaFunction = UIAlertAction(title: "Through my Social Media", style: UIAlertAction.Style.default, handler: { action in
                self.openSocialMedia()
            })
            alertController.addAction(callPhoneFunction)
            alertController.addAction(socialMediaFunction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive))

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func openSocialMedia() {
        guard let url = URL(string: databaseManager.getData(setting: "SOCIAL_MEDIA")) else {
          return
        }

        if verifyUrl(urlString: url.absoluteString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            self.alertController = UIAlertController(title: "Error", message:
                "Innvalid URL.", preferredStyle: .alert)
            self.alertController.addAction(UIAlertAction(title: "OK", style: .default))

            self.present(self.alertController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertController = UIAlertController(title: title, message:
                message, preferredStyle: .alert)
            self.alertController.addAction(UIAlertAction(title: "OK", style: .default))

            self.present(self.alertController, animated: true, completion: nil)
        }
    }
    
    func parseOutputResponse(inputResponse: [String:String]) {
        for (key, value) in inputResponse {
            if key.elementsEqual("result") {
                //showAlert(title: "", message: value)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveData()
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        repositionViewForOnScreenKeyboard(keyboardOn: false)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func loginLogoutButtonTouchUpInside(_ sender: Any) {
        if isUserLoggedIn() {
            self.databaseManager.createData(setting: "LOGGED_IN", value: "", uploadData: false) { returnDictionary in /*CODE HERE*/ }
            //self.databaseManager.createData(setting: "LOGGED_IN_USERNAME", value: "", uploadData: false) { returnDictionary in /*CODE HERE*/ }
            //self.databaseManager.createData(setting: "LOGGED_IN_PASSWORD", value: "", uploadData: false) { returnDictionary in /*CODE HERE*/ }
            //self.databaseManager.createData(setting: "SAVE_USER_AND_PASSWORD", value: "NO", uploadData: false) { returnDictionary in /*CODE HERE*/ }
            loginLogoutButton.setTitle("login", for: UIControl.State.normal)
            self.dismiss(animated: true, completion: nil)
        } else {
            toggleMainMenu(forceHideMenu: false)
            openManageResume()
        }
    }
    
    @IBAction func loadCodeEmailTouchUpInside(_ sender: Any) {
        /*let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "LoadCodeEmail") as! LoadCodeEmailController
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)*/
        toggleMainMenu(forceHideMenu: false)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Load", bundle: nil)
        let loadViewController = storyBoard.instantiateViewController(withIdentifier: "Load") as! LoadViewController
        loadViewController.delegate = self
        self.present(loadViewController, animated: true, completion: nil)
    }
    
    @IBAction func changePasswordButtonTouchUpInside(_ sender: Any) {
        toggleMainMenu(forceHideMenu: false)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "ChangePassword", bundle: nil)
        let changePasswordViewController = storyBoard.instantiateViewController(withIdentifier: "ChangePassword") as! ChangePasswordViewController
        changePasswordViewController.delegate = self
        self.present(changePasswordViewController, animated: true, completion: nil)
    }
    
    @IBAction func helpButtonTouchUpInside(_ sender: Any) {
        toggleMainMenu(forceHideMenu: true)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Help", bundle: nil)
        let helpViewController = storyBoard.instantiateViewController(withIdentifier: "Help") as! HelpViewController
        self.present(helpViewController, animated: true, completion: nil)
    }
    
    @IBAction func activationButtonTouchUpInside(_ sender: Any) {
        toggleMainMenu(forceHideMenu: false)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Activation", bundle: nil)
        let activationViewController = storyBoard.instantiateViewController(withIdentifier: "Activation") as! ActivationViewController
        self.present(activationViewController, animated: true, completion: nil)
    }
    
    func loadData(data: [String:String], uploadImageIfExists: Bool) {
        databaseManager.deleteData(setting: "SUMMARY")
        databaseManager.deleteData(setting: "STRENGTHS")
        databaseManager.deleteData(setting: "PROFESSIONAL_EXPERIENCE")
        databaseManager.deleteData(setting: "OTHER_RELEVANT_EXPERIENCE")
        databaseManager.deleteData(setting: "EDUCATION")
        if let email = data["email"] {
            self.databaseManager.createData(setting: "LOADED_EMAIL", value: email, uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
        }
        
        do {
            if data.count > 0 {
                if let fieldCount = Int(data["fields_count"]!) {
                    for i in 1...fieldCount {
                        let fieldName = data["fieldname_" + String(i)]
                        let fieldValue = data["fieldvalue_" + String(i)]
                        self.databaseManager.updateData(setting: fieldName!, value: fieldValue!, uploadData: false) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
                    }
                    self.loadLocalDataToObjects(uploadImageIfExists: true)
                }
            }
        }
    }
    
    //LOGIN DELEGATE - BEGIN
    func loginLogin(email: String, password: String, data: [String:String]) {
        mode = "login"
        self.loadData(data: data, uploadImageIfExists: true)
    }
    
    func cancelLogin() {
        
    }
    //LOGIN DELEGATE - END
    
    func loadLoad(data: [String:String]) {
        self.loadLocalDataToObjects(uploadImageIfExists: true)
        loadData(data: data, uploadImageIfExists: false)
    }
    
    func cancelLoad() {
        print("cancelLoadButtonTapped")
    }
    
    func registerRegister(data: [String:String]) {
        mode = "register"
        loadData(data: data, uploadImageIfExists: false)
        showAlert(title: "Welcome to Vitasume \(databaseManager.getData(setting: "LOGGED_IN_NAME").decrypt() ?? "")!", message: "")
    }
    
    func cancelRegister() {
        
    }
    
    func saveChangePassword(email: String, oldPassword: String, newPassword: String) {
        
    }
    
    func cancelChangePassword() {
        
    }
    
    func activationActivate(name: String, email: String) {
        
    }
    
    func cancelActivation() {
        
    }
    
    @IBAction func mainMenuButtonTapped(_ sender: Any) {
        toggleMainMenu(forceHideMenu: false)
    }
    //FORMATS THE PHONE NUMBER
    /*func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
    *var fullString = textField.text ?? ""
        fullString.append(string)
        if range.length == 1 {
            textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
        } else {
            textField.text = format(phoneNumber: fullString)
        }
        return false
    }*/
}
