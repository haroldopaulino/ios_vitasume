//
//  DatabaseManager.swift
//  Vitasume
//
//  Created by Harold on 4/17/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DatabaseManager {
    
    func createData(setting: String, value: String, uploadData: Bool, completion: @escaping (_ returnDictionary: [String:String]?)-> ()) {
        deleteData(setting: setting)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return completion(["result": "Could not create data: delegate"]) }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "Settings", in: managedContext)!
        
        do {
            let nsManagedObject = NSManagedObject(entity: userEntity, insertInto: managedContext)
            nsManagedObject.setValue(setting, forKeyPath: "key")
            nsManagedObject.setValue(value, forKeyPath: "value")
            try managedContext.save()
            if !setting.elementsEqual("FIRST_APP_EXECUTION") {
                if (uploadData) {
                    httpRequest(data: [
                        "action": "SAVE_DATA".toBase64(),
                        "email": getData(setting: "LOGGED_IN_USERNAME").decrypt()!.toBase64(),
                        "password": getData(setting: "LOGGED_IN_PASSWORD").decrypt()!.toBase64(),
                        "client_datetime": getTimestamp().toBase64(),
                        "field_name": setting.toBase64(),
                        "field_value": value.toBase64()]){ (returnDict) in
                        return completion(returnDict)
                    }
                }
            }
        } catch let error as NSError {
            completion(["result": "Could not create data: \(error)"])
            print("Database Manager - Create Data Failed. \(error)")
        }
    }
    
    func createBatchData(data: [String: Any], uploadData: Bool, completion: @escaping (_ returnDictionary: [String:String]?)-> ()) {
        for (setting, value) in data {
            if setting != nil && value != nil {
                let aSetting = (setting as? String) ?? ""
                let aValue = (value as? String) ?? ""
                
                
                deleteData(setting: aSetting)
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return completion(["result": "Could not create data: delegate"]) }
                let managedContext = appDelegate.persistentContainer.viewContext
                let userEntity = NSEntityDescription.entity(forEntityName: "Settings", in: managedContext)!
                
                do {
                    let nsManagedObject = NSManagedObject(entity: userEntity, insertInto: managedContext)
                    nsManagedObject.setValue(aSetting, forKeyPath: "key")
                    nsManagedObject.setValue(value, forKeyPath: "value")
                    try managedContext.save()
                    if !aSetting.elementsEqual("FIRST_APP_EXECUTION") {
                        if (uploadData) {
                            httpRequest(data: [
                                "action": "SAVE_DATA".toBase64(),
                                "email": getData(setting: "EMAIL").toBase64(),
                                "password": getData(setting: "PASSWORD").toBase64(),
                                "client_datetime": getTimestamp().toBase64(),
                                "field_name": aSetting.toBase64(),
                                "field_value": aValue.toBase64()]){ (returnDict) in
                                return completion(returnDict)
                            }
                        }
                    }
                } catch let error as NSError {
                    completion(["result": "Could not create data: \(error)"])
                    print("Database Manager - Create Data Failed. \(error)")
                }
                
                
                print("Response: \(aSetting) = \(String(describing: aValue.fromBase64()))")
            }
        }
    }
    
    func createLocalData(setting: String, value: String) {
        deleteData(setting: setting)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "Settings", in: managedContext)!
        
        do {
            let nsManagedObject = NSManagedObject(entity: userEntity, insertInto: managedContext)
            nsManagedObject.setValue(setting, forKeyPath: "key")
            nsManagedObject.setValue(value, forKeyPath: "value")
            try managedContext.save()
        } catch let error as NSError {
            print("Database Manager - Create Local Data Failed. \(error)")
        }
    }
    
    func getData(setting: String) -> String {
        var output = ""
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return "" }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                let dataKey = data.value(forKey: "key") as! String
                let dataValue = data.value(forKey: "value") as! String
                
                if dataKey.elementsEqual(setting) {
                    output = dataValue
                }
            }
            
        } catch {
            print("Database Manager - Get Data Failed. \(error)")
        }
        return output
    }
        
    func updateData(setting: String, value: String, uploadData: Bool, completion: @escaping (_ returnDictionary: [String:String]?)-> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return completion(["result": "Could not update data: delegate"]) }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Settings")
        fetchRequest.predicate = NSPredicate(format: "key = %@", setting)
        do {
            let test = try managedContext.fetch(fetchRequest)
            if test.count == 0 {//THE SETTING DOES NOT EXIST AND NEEDS TO BE CREATED INSTEAD
                createData(setting: setting, value: value, uploadData: uploadData) { returnDictionary in completion(returnDictionary) }
            } else {
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(setting, forKey: "key")
                objectUpdate.setValue(value, forKey: "value")
                do {
                    try managedContext.save()
                    if (uploadData) {
                        httpRequest(data: [
                            "action": "SAVE_DATA".toBase64(),
                            "email": getData(setting: "LOGGED_IN_USERNAME").decrypt()!.toBase64(),
                            "password": getData(setting: "LOGGED_IN_PASSWORD").decrypt()!.toBase64(),
                            "client_datetime": getTimestamp().toBase64(),
                            "field_name": setting.toBase64(),
                            "field_value": value.toBase64()]){ (returnDict) in
                            return completion(returnDict)
                        }
                    }
                } catch {
                    print("Database Manager - Update Data Failed. \(error)")
                    completion(["result": "Could not update data: \(error)"])
                }
            }
        } catch {
            print(error)
        }
    }
        
     func deleteData(setting: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            fetchRequest.predicate = NSPredicate(format: "key = %@", setting)
            let test = try managedContext.fetch(fetchRequest)
            if test.count > 0 {
                let objectToDelete = test[0] as! NSManagedObject
                managedContext.delete(objectToDelete)
                do {
                    try managedContext.save()
                } catch {
                    print("Database Manager - Delete Data Failed. \(error)")
                }
            }
        }  catch {
            print("Database Manager - Delete Data Failed. \(error)")
        }
    }
}
