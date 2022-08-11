//
//  OptionsViewController.swift
//  RussMyers
//
//  Created by Harold on 4/15/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class OptionsViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var summaryStrengthsView: UIView!
    @IBOutlet weak var professionalExperienceOtherRelevantExperienceView: UIView!
    @IBOutlet weak var educationView: UIView!
    
    @IBOutlet weak var summaryImage: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var strengthsImage: UIImageView!
    @IBOutlet weak var strengthsLabel: UILabel!
    @IBOutlet weak var professionalExperienceImage: UIImageView!
    @IBOutlet weak var professionalExperienceLabel: UILabel!
    @IBOutlet weak var otherRelevantExperienceImage: UIImageView!
    @IBOutlet weak var otherRelevantExperienceLabel: UILabel!
    @IBOutlet weak var educationImage: UIImageView!
    @IBOutlet weak var educationLabel: UILabel!
    
    @IBOutlet weak var saveButtonImage: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    
    let databaseManager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSummary()
        setupStrengths()
        setupProfessionalExperience()
        setupOtherRelevantExperience()
        setupEducation()
    }
    
    func setupSummary() {
        let summaryImageTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.showSummary))
        summaryImageTapGetsure.numberOfTapsRequired = 1
        summaryImage.addGestureRecognizer(summaryImageTapGetsure)
        summaryImage.isUserInteractionEnabled = true
        
        let summaryLabelTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.showSummary))
        summaryLabelTapGetsure.numberOfTapsRequired = 1
        summaryLabel.addGestureRecognizer(summaryLabelTapGetsure)
        summaryLabel.isUserInteractionEnabled = true
    }
    
    func setupStrengths() {
        let strengthsImageTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.showStrengths))
        strengthsImageTapGetsure.numberOfTapsRequired = 1
        strengthsImage.addGestureRecognizer(strengthsImageTapGetsure)
        strengthsImage.isUserInteractionEnabled = true
        
        let strengthsLabelTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.showStrengths))
        strengthsLabelTapGetsure.numberOfTapsRequired = 1
        strengthsLabel.addGestureRecognizer(strengthsLabelTapGetsure)
        strengthsLabel.isUserInteractionEnabled = true
    }
    
    func setupProfessionalExperience() {
        let professionalExperienceImageTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.showProfessionalExperience))
        professionalExperienceImageTapGetsure.numberOfTapsRequired = 1
        professionalExperienceImage.addGestureRecognizer(professionalExperienceImageTapGetsure)
        professionalExperienceImage.isUserInteractionEnabled = true
        
        let professionalExperienceLabelTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.showProfessionalExperience))
        professionalExperienceLabelTapGetsure.numberOfTapsRequired = 1
        professionalExperienceLabel.addGestureRecognizer(professionalExperienceLabelTapGetsure)
        professionalExperienceLabel.isUserInteractionEnabled = true
    }
    
    func setupOtherRelevantExperience() {
        let otherRelevantExperienceImageTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.showOtherRelevantExperience))
        otherRelevantExperienceImageTapGetsure.numberOfTapsRequired = 1
        otherRelevantExperienceImage.addGestureRecognizer(otherRelevantExperienceImageTapGetsure)
        otherRelevantExperienceImage.isUserInteractionEnabled = true
        
        let otherRelevantExperienceLabelTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.showOtherRelevantExperience))
        otherRelevantExperienceLabelTapGetsure.numberOfTapsRequired = 1
        otherRelevantExperienceLabel.addGestureRecognizer(otherRelevantExperienceLabelTapGetsure)
        otherRelevantExperienceLabel.isUserInteractionEnabled = true
    }
    
    func setupEducation() {
        let educationImageTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.showEducation))
        educationImageTapGetsure.numberOfTapsRequired = 1
        educationImage.addGestureRecognizer(educationImageTapGetsure)
        educationImage.isUserInteractionEnabled = true
        
        let educationLabelTapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.showEducation))
        educationLabelTapGetsure.numberOfTapsRequired = 1
        educationLabel.addGestureRecognizer(educationLabelTapGetsure)
        educationLabel.isUserInteractionEnabled = true
    }
    
    func callPopover(settingKey: String, title: String) {
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
        let normalString = NSMutableAttributedString(string:databaseManager.getData(setting: settingKey).replacingOccurrences(of: "\\n", with: "\n"), attributes:attrs1)
        showPopover(settingKey: settingKey, withTitle: title, withContents: normalString)
    }
    
    @objc func showSummary() {
        callPopover(settingKey: "SUMMARY", title: "SUMMARY")
        /*let boldText = "MANAGING DIRECTOR and GENERAL MANAGER"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)

        let normalText = "\n\nManaging Director and General Manager with a demonstrated history of product development and customer satisfaction.\n\nSkilled in continuous improvement, leadership, business process improvement, 5S, and Six Sigma.\n\nA strong business development professional with practice in solving customer problems in unique markets from jewelry to construction.\n\nA process-driven leader with a foundation in Mechanical Engineering. Skilled at problem-solving with an ability to evaluate new industries, build teams with intentional culture, drive customer-centric results, and identify priorities to balance P&L responsibility with limited resources."
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
        let normalString = NSMutableAttributedString(string:normalText, attributes:attrs1)

        attributedString.append(normalString)
        showPopover(inputTitle: "SUMMARY", inputContents: attributedString)*/
    }
    
    @objc func showStrengths() {
        callPopover(settingKey: "STRENGTHS", title: "STRENGTHS")
        /*
         let normalText = "* Recognize and define customer concerns.\n\n* Engage customers in support of strategy.\n\n* Interface with key stakeholders and help them succeed.\n\n* Understand value to prioritize needs.\n\n* Align strategy and execution to the delivery of value to customers.\n\n* Establish and communicate a clear vision of success."
         let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
         let normalString = NSMutableAttributedString(string:normalText, attributes:attrs1)
         showPopover(inputTitle: "STRENGTHS", inputContents: normalString)*/
    }
    
    @objc func showProfessionalExperience() {
        callPopover(settingKey: "PROFESSIONAL_EXPERIENCE", title: "PROFESSIONAL EXPERIENCE")
        /*
        var boldText = "Apergy - US Synthetic Corporation"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)

        var normalText = ", Orem, UT September 1997 – April 2020\n(Comprises 500- 1000 employees serving the oil and gas industry with synthetic diamond).\n\n"
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
        var normalString = NSMutableAttributedString(string:normalText, attributes:attrs1)
        attributedString.append(normalString)
        
        boldText = "General Manager"
        let attributedString2 = NSMutableAttributedString(string:boldText, attributes:attrs)
        attributedString.append(attributedString2)

        normalText = "\nMining and Construction Division (April 2008 – April 2020)\n\nThis division was acquired as part of a downstream business development strategy to reach end users. Starting with a small team of two employees, it quickly grew to $10M in revenue.\n\nDefining vision and culture for the team through product and project management was very rewarding. Priorities and Kanban were critical in balancing scope with P&L responsibilities.\n\nUnderstanding the customer need beyond apparent requests drove customer satisfaction.\n\nRelocated to St Louis to acquire and manage downstream business:\n\n* Created company structure and organization.\n* Generated 53% revenue growth over seven years.\n* Increased profitability by 65%.\n* Evaluated CapEx investment and ROI strategy to create internal manufacturing.\n* Increased inventory turns by 600%.\n* Reduced inventory value by 83%.\n* Created customer-centric strategy that built brand confidence.\n* Developed sales and marketing strategy creating strong industry brand recognition.\nFormed partnerships through customer, pricing, and consignment contracts.\nCreated a strong intellectual property position resulting in 8 patents and several disclosures.\n* General Manager, Suncrest HPHT Process (June 2003 – March 2008)\nThis internal business was grown organically through the development of a high pressure high temperature process to improve the color of natural diamond in the wholesale diamond industry. Customer obsessed support and market saturation were key strategies in developing the business. Face to face customer interaction was critical to developing trust and relationships.\n\n* Generated revenue growth from inception to $1.5M in sales.\n* Transformed a unique business model into a corporate structure.\n* Traveled extensively acquiring customers building trust in the product.\n* Chosen to speak on several industry panels and at educational institutions: Gemological Institute of America, Gemological Association of Hong Kong, American Gem Trade Association, International Colored Gemstone Association.\n* Gained new customers through distinct market strategies and support material.\n* Developed incremental revenue stream with new product offerings creating market disruption.\n* Provided analysis of new market that determined ROI and CapEx requirements."
        normalString = NSMutableAttributedString(string:normalText, attributes:attrs1)
        attributedString.append(normalString)
        
        
        showPopover(inputTitle: "PROFESSIONAL EXPERIENCE", inputContents: attributedString)*/
    }
    
    @objc func showOtherRelevantExperience() {
        callPopover(settingKey: "OTHER_RELEVANT_EXPERIENCE", title: "OTHER RELEVANT EXPERIENCE")
        /*var boldText = "Customer Account Manager"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)

        var normalText = "\nWorked closely with customer accounts to engineer new product offerings that would make their businesses successful. Used 5-why methodology to understand need and define customer specifications/deliverables.\n\n"
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
        var normalString = NSMutableAttributedString(string:normalText, attributes:attrs1)
        attributedString.append(normalString)
        
        boldText = "Research and Development Manager"
        let attributedString2 = NSMutableAttributedString(string:boldText, attributes:attrs)
        attributedString.append(attributedString2)

        normalText = "\nUsed statistical and analytical methods to develop new products for industry use. Designed product specification and process integration for product launches."
        normalString = NSMutableAttributedString(string:normalText, attributes:attrs1)
        attributedString.append(normalString)
        
        
        showPopover(inputTitle: "OTHER RELEVANT EXPERIENCE", inputContents: attributedString)*/
    }
    
    @objc func showEducation() {
        callPopover(settingKey: "EDUCATION", title: "EDUCATION")
        /*
        var boldText = "Master of Business Administration"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)

        var normalText = "\nOperational Excellence – Utah State University, 2016\n\n"
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
        var normalString = NSMutableAttributedString(string:normalText, attributes:attrs1)
        attributedString.append(normalString)
        
        boldText = "Bachelor of Science - Mechanical Engineering"
        let attributedString2 = NSMutableAttributedString(string:boldText, attributes:attrs)
        attributedString.append(attributedString2)

        normalText = "\nBrigham Young University"
        normalString = NSMutableAttributedString(string:normalText, attributes:attrs1)
        attributedString.append(normalString)
        
        
        showPopover(inputTitle: "SUMMARY", inputContents: attributedString)*/
    }
    
    func showPopover(settingKey: String, withTitle: String, withContents: NSAttributedString) {
        let storyBoard = UIStoryboard(name: "PopoverContent", bundle: nil)
        let popoverContentController = storyBoard.instantiateViewController(withIdentifier: "PopoverContent") as! PopoverContentController
        popoverContentController.setContents(setting: settingKey, inputTitle: withTitle, inputContent: withContents)
        popoverContentController.modalPresentationStyle = .popover

        if let popoverPresentationController = popoverContentController.popoverPresentationController {
            var coord = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            coord.origin.x = (self.view.frame.width / 2) + 40
            coord.origin.y = (self.view.frame.height) - 40
            
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = coord
            popoverPresentationController.delegate = self
            self.present(popoverContentController, animated: false, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

