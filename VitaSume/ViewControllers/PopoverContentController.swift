//
//  PopoverContentController.swift
//  RussMyers
//
//  Created by Harold on 4/15/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import Foundation
import UIKit

class PopoverContentController: UIViewController {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var dataSetting = ""
    var title1 = ""
    var content = NSAttributedString()
    let databaseManager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleText.text = title1
        contentText.attributedText = content
        setupButtons()
    }
    
    func areLoggedInEmailAndLoadedEmailTheSame() -> Bool {
        return self.databaseManager.getData(setting: "LOADED_EMAIL") == self.databaseManager.getData(setting: "LOGGED_IN_USERNAME").decrypt()
    }
    
    private func setupButtons() {
        let cancelButtonTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.dismissPopover))
        cancelButtonTapGetsure.numberOfTapsRequired = 1
        cancelButton.addGestureRecognizer(cancelButtonTapGetsure)
        
        if isUserLoggedIn() &&
            isAppActivated() &&
            areLoggedInEmailAndLoadedEmailTheSame() {
            let saveButtonTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.saveContents))
            saveButtonTapGetsure.numberOfTapsRequired = 1
            saveButton.addGestureRecognizer(saveButtonTapGetsure)
        } else {
            saveButton.isHidden = true
            cancelButton.setTitle("ok", for: UIControl.State.normal)
        }
    }
    
    @objc private func dismissPopover() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveContents() {
        databaseManager.updateData(setting: dataSetting, value: contentText.text ?? "", uploadData: true) { returnDictionary in self.parseOutputResponse(inputResponse: returnDictionary!) }
        dismissPopover()
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message:
                message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func setContents(setting: String, inputTitle: String, inputContent: NSAttributedString) {
        dataSetting = setting
        title1 = inputTitle
        content = inputContent
    }
    
    func parseOutputResponse(inputResponse: [String:String]) {
        for (key, value) in inputResponse {
            if key.elementsEqual("result") {
                showAlert(title: "", message: value)
            }
        }
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
