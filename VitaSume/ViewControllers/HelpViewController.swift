//
//  HelpViewController.swift
//  VitaSume
//
//  Created by Harold on 7/27/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AVKit

class CustomAVPlayerViewController: AVPlayerViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
    }
}

class HelpViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var menuTitleTextview: UILabel!
    
    @IBOutlet weak var loadResumeImageview: UIImageView!
    @IBOutlet weak var loadResumeButton: UIButton!
    @IBOutlet weak var registerImageview: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginImageview: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var logoutImageview: UIImageView!
    @IBOutlet weak var managementButton: UIButton!
    @IBOutlet weak var managementImageview: UIImageView!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var changePasswordImageview: UIImageView!
    
    var player = AVPlayer(url: URL(string: "https://haroldopaulino.com/web/vitasume/media/login.m4v")!)
    var playerViewController = CustomAVPlayerViewController()
    
    func showMainMenu() {
        menuTitleTextview.isHidden    = false
        loadResumeButton.isHidden     = false
        registerButton.isHidden       = false
        loginButton.isHidden          = false
        logoutButton.isHidden         = false
        managementButton.isHidden     = false
        changePasswordButton.isHidden = false
        
        loadResumeImageview.isHidden     = false
        registerImageview.isHidden       = false
        loginImageview.isHidden          = false
        logoutImageview.isHidden         = false
        managementImageview.isHidden     = false
        changePasswordImageview.isHidden = false
    }
    
    func hideMainMenu() {
        menuTitleTextview.isHidden    = true
        loadResumeButton.isHidden     = true
        registerButton.isHidden       = true
        loginButton.isHidden          = true
        logoutButton.isHidden         = true
        managementButton.isHidden     = true
        changePasswordButton.isHidden = true
        
        loadResumeImageview.isHidden     = true
        registerImageview.isHidden       = true
        loginImageview.isHidden          = true
        logoutImageview.isHidden         = true
        managementImageview.isHidden     = true
        changePasswordImageview.isHidden = true
    }
    
    func play(video: String) {
        player = AVPlayer(url: URL(string: "https://haroldopaulino.com/web/vitasume/media/\(video).m4v")!)
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            self.playerViewController.player!.play()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

    }
    
    @objc func playerDidFinishPlaying() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func setupView() {
        mainView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        mainView.alpha = 0;
        self.mainView.frame.origin.y = self.mainView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.mainView.alpha = 1.0;
            self.mainView.frame.origin.y = self.mainView.frame.origin.y - 50
        })
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loadResumeButtonTouchUpInside(_ sender: Any) {
        play(video: "vitasume_load")
    }
    
    @IBAction func registerResumeButtonTouchUpInside(_ sender: Any) {
        play(video: "vitasume_register")
    }
    
    @IBAction func loginButtonTouchUpInside(_ sender: Any) {
        play(video: "vitasume_login")
    }
    
    @IBAction func logoutButtonTouchUpInside(_ sender: Any) {
        play(video: "vitasume_logout")
    }
    
    @IBAction func managementButtonTouchUpInside(_ sender: Any) {
        play(video: "vitasume_manage")
    }
    
    @IBAction func updateResumeButtonTouchUpInside(_ sender: Any) {
        play(video: "update_resume")
    }
    
    @IBAction func changePasswordButtonTouchUpInside(_ sender: Any) {
        play(video: "vitasume_change_password")
    }
    
}
