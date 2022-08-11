//
//  RegisterDelegate.swift
//  iResume
//
//  Created by Harold on 6/2/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

protocol RegisterDelegate: class {
    func registerRegister(data: [String:String])
    func cancelRegister()
}
