//
//  Utilities.swift
//  RussMyers
//
//  Created by Harold on 4/22/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CommonCrypto

let databaseManager = DatabaseManager()
let mainUrl = "https://haroldopaulino.com/web/vitasume/gateway.php"
let mainImageName = "main_image.jpeg"
let appTrialPeriodInDays = 15

enum Error: Swift.Error {
    case encryptionError(status: CCCryptorStatus)
    case decryptionError(status: CCCryptorStatus)
    case keyDerivationError(status: CCCryptorStatus)
}

func encryptData(data: Data, key: Data, iv: Data) throws -> Data {
    // Output buffer (with padding)
    let outputLength = data.count + kCCBlockSizeAES128
    var outputBuffer = Array<UInt8>(repeating: 0, count: outputLength)
    var numBytesEncrypted = 0
    let status = CCCrypt(CCOperation(kCCEncrypt),
                         CCAlgorithm(kCCAlgorithmAES),
                         CCOptions(kCCOptionPKCS7Padding),
                         Array(key),
                         kCCKeySizeAES256,
                         Array(iv),
                         Array(data),
                         data.count,
                         &outputBuffer,
                         outputLength,
                         &numBytesEncrypted)
    guard status == kCCSuccess else {
        throw Error.encryptionError(status: status)
    }
    let outputBytes = iv + outputBuffer.prefix(numBytesEncrypted)
    return Data(outputBytes)
}

func decryptData(data cipherData: Data, key: Data) throws -> Data {
    // Split IV and cipher text
    let iv = cipherData.prefix(kCCBlockSizeAES128)
    let cipherTextBytes = cipherData.suffix(from: kCCBlockSizeAES128)
    let cipherTextLength = cipherTextBytes.count
    // Output buffer
    var outputBuffer = Array<UInt8>(repeating: 0, count: cipherTextLength)
    var numBytesDecrypted = 0
    let status = CCCrypt(CCOperation(kCCDecrypt),
                         CCAlgorithm(kCCAlgorithmAES),
                         CCOptions(kCCOptionPKCS7Padding),
                         Array(key),
                         kCCKeySizeAES256,
                         Array(iv),
                         Array(cipherTextBytes),
                         cipherTextLength,
                         &outputBuffer,
                         cipherTextLength,
                         &numBytesDecrypted)
    guard status == kCCSuccess else {
        throw Error.decryptionError(status: status)
    }
    // Discard padding
    let outputBytes = outputBuffer.prefix(numBytesDecrypted)
    return Data(outputBytes)
}

func checkIfImageExistsAndDownload(imageName: String, imageView: UIImageView, completion: @escaping (_ returnMessage: String?)-> ()) {
    let mainImageWasDownloaded = databaseManager.getData(setting: "MAIN_IMAGE_WAS_DOWNLOADED")
    
    if !mainImageWasDownloaded.elementsEqual("YES") {
        downloadImage(from: "https://haroldopaulino.com/web/vitasume/gateway.php",
                      data: ["action": "DOWNLOAD_IMAGE".toBase64(),
                             "email": databaseManager.getData(setting: "EMAIL").toBase64(),
                             "password": databaseManager.getData(setting: "PASSWORD").toBase64(),
                             "client_datetime": getTimestamp().toBase64()]) { (imageData) in
                            if imageData != nil {
                                if let parsedData = UIImage(data: imageData!) {
                                    DispatchQueue.main.async {
                                        databaseManager.createLocalData(setting: "MAIN_IMAGE_WAS_DOWNLOADED", value: "YES")
                                        saveImageToDocumentDirectory(imageData: parsedData,//UIImage(data: parsedData)!,
                                                                     imageName: "main_image.jpeg",
                                                                     upload: false)
                                        imageView.image = parsedData
                                        return completion("GOOD")
                                    }
                                } else {
                                    print("Error loading image");
                                    return completion("BAD")
                                }
                            }
        }
    }
    return completion("BAD")
}

func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
    guard !phoneNumber.isEmpty else { return "" }
    guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
    let r = NSString(string: phoneNumber).range(of: phoneNumber)
    var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")

    if number.count > 10 {
        let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
        number = String(number[number.startIndex..<tenthDigitIndex])
    }

    if shouldRemoveLastDigit {
        let end = number.index(number.startIndex, offsetBy: number.count-1)
        number = String(number[number.startIndex..<end])
    }

    if number.count < 7 {
        let end = number.index(number.startIndex, offsetBy: number.count)
        let range = number.startIndex..<end
        number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)

    } else {
        let end = number.index(number.startIndex, offsetBy: number.count)
        let range = number.startIndex..<end
        number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
    }

    return number
}

func httpRequest(data: [String: Any], completion: @escaping(_ returnDictionary: [String:String]?)-> ()) {
    var outputDictionary: NSDictionary!
    let url = URL(string: mainUrl)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = data.percentEncoded()
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        print("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
        if let error = error {
            print("error: \(error)")
            return completion(["response":"\(error)"])
        } else {
            let rawResponse = String(decoding: data!, as: UTF8.self)
            print("HTTP Response:")
            print(rawResponse)
            outputDictionary = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? NSDictionary
            var tmpDictionary : [String:String] = [:]
            if outputDictionary != nil {
                for (key, value) in outputDictionary {
                    if key != nil && value != nil {
                        let stringKey = (key as? String) ?? ""
                        let stringValue = (value as? String) ?? ""
                        tmpDictionary[stringKey] = stringValue.fromBase64()! as String
                        print("Response: \(stringKey) = \(String(describing: stringValue.fromBase64()))")
                    }
                }
                print("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
            }
            return completion(tmpDictionary)
        }
    }
    task.resume()
    //sleep(1)
}

func uploadImage(paramName: String, fileName: String, image: UIImage) {
    let url = URL(string: mainUrl)

    // generate boundary string using a unique per-app string
    let boundary = UUID().uuidString

    let session = URLSession.shared

    // Set the URLRequest to POST and to the specified URL
    var urlRequest = URLRequest(url: url!)
    urlRequest.httpMethod = "POST"

    // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
    // And the boundary is also set here
    urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var data = Data()

    // Add the image data to the raw http request data
    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
    data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
    data.append(image.pngData()!)

    data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

    // Send a POST request to the URL, with the data we created earlier
    session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
        if error == nil {
            let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
            if let json = jsonData as? [String: Any] {
                print(json)
            }
        }
    }).resume()
}

func downloadImage(from urlString: String, data: [String: Any], completionHandler: @escaping (_ data: Data?) -> ()) {
    let session = URLSession.shared
    let url = URL(string: urlString)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = data.percentEncoded()
        
    let dataTask = session.dataTask(with: request) { (data, response, error) in
        if error != nil {
            print("Error fetching the image!")
            completionHandler(nil)
        } else {
            if let parsedData = UIImage(data: data!) {
                DispatchQueue.main.async {
                    databaseManager.createLocalData(setting: "MAIN_IMAGE_WAS_DOWNLOADED", value: "YES")
                    saveImageToDocumentDirectory(imageData: parsedData,//UIImage(data: parsedData)!,
                                                 imageName: "main_image.jpeg",
                                                 upload: false)
                }
            } else {
                print("Error loading image");
            }
            completionHandler(data)
        }
    }
        
    dataTask.resume()
}

func getTimestamp() -> String {
    let dateFormatter = DateFormatter()
    let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
    dateFormatter.locale = enUSPosixLocale
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.calendar = Calendar(identifier: .gregorian)

    let iso8601String = dateFormatter.string(from: Date())
    return iso8601String
}

func saveImageToDocumentDirectory(imageData: UIImage, imageName: String, upload: Bool ) {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(imageName)
    
    if let parsedImageData = imageData
        .resized(toWidth: CGFloat(1200))! //extension that resizes the image to the desired width and calculates the height proporcionally
        .jpegData(compressionQuality: 0.5) {
        do {
            try parsedImageData.write(to: fileURL)
            /*httpRequest(data: [
                "action": "SAVE_DATA".toBase64(),
                "email": databaseManager.getData(setting: "EMAIL").toBase64(),
                "password": databaseManager.getData(setting: "PASSWORD").toBase64(),
                "client_datetime": getTimestamp().toBase64(),
                "field_name": "MAIN_IMAGE".toBase64(),
                "field_value": base64EncodeImage(imageData : imageData).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)]){ (returnDict) in
                        //return completion(returnDict)
                    }*/
            if upload {
                uploadImage(paramName: "image", fileName: databaseManager.getData(setting: "EMAIL"), image: UIImage(data: parsedImageData)!)
            }
            print("file saved")
        } catch {
            print("error saving file:", error)
        }
    }
}

func loadImageFromDocumentDirectory(imageName : String, imageView: UIImageView) {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(imageName)
    
    //CHECK IF THE IMAGE EXISTS IN THE "fileURL" LOCATION
    guard let imageData = NSData(contentsOf: fileURL) else {
        imageView.image = UIImage.init(named: "main_image.jpeg")!
        return
    }
    
    if let parsedData = UIImage(data: imageData as Data) {
        imageView.image = parsedData
    } else {
        imageView.image = UIImage.init(named: "main_image.jpeg")!
    }
}

func base64EncodeImage(imageData : UIImage) -> String {
    return imageData.pngData()! .base64EncodedString()
}

func base64DecodeImage(base64EncodedImage : String) -> UIImage {
    let url = URL(string: String(format:"data:application/octet-stream;base64,%@", base64EncodedImage))
    do {
        let imageData = try Data(contentsOf: url!)
        return UIImage(data: imageData) ?? (UIImage.init(named: "main_image.jpeg")!)
    } catch {

    }
    return UIImage.init(named: "main_image.jpeg")!
}

func alert(title: String, message: String, buttonText: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: buttonText, style: .default, handler: nil))
    return alert
}

func isUserLoggedIn() -> Bool {
    let loggedInStatus = databaseManager.getData(setting: "LOGGED_IN").decrypt()!
    let loggedInUsername = databaseManager.getData(setting: "LOGGED_IN_USERNAME").decrypt()!
    let loggedInPassword = databaseManager.getData(setting: "LOGGED_IN_PASSWORD").decrypt()!
    if  loggedInStatus.elementsEqual("YES") &&
        !loggedInUsername.elementsEqual("") &&
        !loggedInPassword.elementsEqual("") {
        return true
    }
    return false
}

func wasAppPurchased() -> Bool {
    let purchaseStatus = databaseManager.getData(setting: "PURCHASE_STATUS")
    if purchaseStatus.elementsEqual("YES") {
        return true
    }
    return false
}

func isAppActivated() -> Bool {
    let purchaseStatus = databaseManager.getData(setting: "PURCHASE_STATUS")
    
    let currentAppInstallDays = appInstallDays()
    
    if  (!purchaseStatus.elementsEqual("YES") && currentAppInstallDays <= appTrialPeriodInDays) ||
        (purchaseStatus.elementsEqual("YES")) {
        return true
    }
    return false
}

func appInstallDays() -> Int {
    let currentDate = Date()
    
    let appInstallDateFormatter = DateFormatter()
    appInstallDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let appInstallTimestamp = appInstallDateFormatter.date(from: databaseManager.getData(setting: "APP_INSTALL_TIMESTAMP"))
    
    let appInstallDays = Calendar.current.dateComponents([.day], from: appInstallTimestamp!, to: currentDate).day
    
    
    return appInstallDays ?? 0
}

func verifyUrl (urlString: String?) -> Bool {
    if let urlString = urlString {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}
