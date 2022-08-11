//
//  LoadCodeEmail.swift
//  iResume
//
//  Created by Harold on 5/31/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {
    
    
    @IBOutlet var loadMainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loadTextfield: UITextField!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loadSegment: UISegmentedControl!
    
    var delegate: LoadDelegate?
    var selectedOption = "By Email"
    let databaseManager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTextfield.becomeFirstResponder()
        segmentedStyle()
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
    
    func segmentedStyle() {
        let font = UIFont.systemFont(ofSize: 19)

        let normalAttribute: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.gray]
        loadSegment.setTitleTextAttributes(normalAttribute, for: .normal)

        let selectedAttribute: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.blue]
        loadSegment.setTitleTextAttributes(selectedAttribute, for: .selected)
    }
    
    func buttonsStyle() {
        loadButton.layer.cornerRadius = 5
        loadButton.layer.borderWidth = 1
        loadButton.layer.borderColor = UIColor.white.cgColor
        
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.white.cgColor
    }
    
    func setupView() {
        loadMainView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        loadMainView.alpha = 0;
        self.loadMainView.frame.origin.y = self.loadMainView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.loadMainView.alpha = 1.0;
            self.loadMainView.frame.origin.y = self.loadMainView.frame.origin.y - 50
        })
    }
    
    func processResponse(data: [String:String]) {
        self.removeSpinner()
        if let returnValue = data["return"] {
            if returnValue.elementsEqual("BAD") {
                DispatchQueue.main.async {
                    self.present(alert(title: data["message"] ?? "Communication Error", message: "", buttonText: "OK"), animated: true)
                }
                self.delegate?.cancelLoad()
            } else {
                DispatchQueue.main.async {
                    self.delegate?.loadLoad(data: data)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.present(alert(title: data["message"] ?? "Communication Error", message: "", buttonText: "OK"), animated: true)
            }
            self.delegate?.cancelLoad()
        }
    }
    
    @IBAction func loadButtonTouchUpInside(_ sender: Any) {
        loadTextfield.resignFirstResponder()
        //self.databaseManager.createData(setting: "LOGGED_IN", value: "", uploadData: false) { returnDictionary in /*CODE HERE*/ }
        self.showSpinner(onView: self.view)
        httpRequest(data: [
            "action" : "LOAD_DATA".toBase64(),
            "value"  : loadTextfield.text!.toBase64(),
            "option" : selectedOption.toBase64()]){ (returnDict) in
                self.processResponse(data: returnDict!)
        }
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        loadTextfield.resignFirstResponder()
        delegate?.cancelLoad()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loadSegmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                loadTextfield.placeholder = "enter email address"
                selectedOption = "by_email"
                break
            case 1:
                loadTextfield.placeholder = "enter resume code"
                selectedOption = "by_code"
                break
            default:
                break
        }
    }
}
