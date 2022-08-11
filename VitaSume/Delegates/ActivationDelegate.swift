//
//  ActivateDelegate.swift
//  iResume
//
//  Created by Harold on 6/22/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

protocol ActivationDelegate: class {
    func activationActivate(name: String, email: String)
    func cancelActivation()
}
