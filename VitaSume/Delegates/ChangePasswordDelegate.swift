//
//  ChangePasswordDelegate.swift
//  iResume
//
//  Created by Harold on 6/12/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

protocol ChangePasswordDelegate: class {
    func saveChangePassword(email: String, oldPassword: String, newPassword: String)
    func cancelChangePassword()
}
