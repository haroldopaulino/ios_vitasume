//
//  ForgotPasswordDelegate.swift
//  iResume
//
//  Created by Harold on 6/11/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

protocol ForgotPasswordDelegate: class {
    func finishForgotPassword(email: String, code: String, newPassword: String)
    func cancelForgotPassword()
}
