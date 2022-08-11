//
//  ManageDelegate.swift
//  iResume
//
//  Created by Harold on 6/13/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

protocol LoginDelegate: class {
    func loginLogin(email: String, password: String, data: [String:String])
    func cancelLogin()
}
