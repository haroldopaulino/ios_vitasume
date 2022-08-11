//
//  Extensions.swift
//  RussMyers
//
//  Created by Harold on 4/23/20.
//  Copyright © 2020 Seven Even. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

var vSpinner : UIView?

extension String {
    func fromBase64() -> String? {
            guard let data = Data(base64Encoded: self) else {
                    return nil
            }
            return String(data: data, encoding: .utf8)
    }
    func toBase64() -> String {
            return Data(self.utf8).base64EncodedString()
    }
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    //func encrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
    //func encrypt(key:String = "9Z8M4HCV7S0SM3HDB2HG27NFNMW1HQWO", iv:String = "AA-salt-BBCCDD--", options:Int = kCCOptionPKCS7Padding) -> String? {
    func encrypt() -> String? {
        let key = "9Z8M4HCV7S0SM3HDB2HG27NFNMW1HQWO" // 32 char pass key
        let iv = "AA-salt-BBCCDD--" // should be of 16 characters.
        let options = kCCOptionPKCS7Padding
        if let keyData = key.data(using: String.Encoding.utf8),
            let data = self.data(using: String.Encoding.utf8),
            let cryptData    = NSMutableData(length: Int((data.count)) + kCCBlockSizeAES128) {
                let keyLength              = size_t(kCCKeySizeAES128)
                let operation: CCOperation = UInt32(kCCEncrypt)
                let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
                let options:   CCOptions   = UInt32(options)

                var numBytesEncrypted :size_t = 0

                let cryptStatus = CCCrypt(operation,
                                          algoritm,
                                          options,
                                          (keyData as NSData).bytes, keyLength,
                                          iv,
                                          (data as NSData).bytes, data.count,
                                          cryptData.mutableBytes, cryptData.length,
                                          &numBytesEncrypted)

                if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                    cryptData.length = Int(numBytesEncrypted)
                    let base64cryptString = cryptData.base64EncodedString(options: .lineLength64Characters)
                    return base64cryptString
                } else {
                    return ""
                }
            }
        return ""
    }

    //func decrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
    func decrypt() -> String? {
        let key = "9Z8M4HCV7S0SM3HDB2HG27NFNMW1HQWO" // 32 char pass key
        let iv = "AA-salt-BBCCDD--" // should be of 16 characters.
        let options = kCCOptionPKCS7Padding
        if let keyData = key.data(using: String.Encoding.utf8),
            let data = NSData(base64Encoded: self, options: .ignoreUnknownCharacters),
            let cryptData    = NSMutableData(length: Int((data.length)) + kCCBlockSizeAES128) {

            let keyLength              = size_t(kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCDecrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(options)

            var numBytesEncrypted :size_t = 0

            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      iv,
                                      data.bytes, data.length,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let unencryptedMessage = String(data: cryptData as Data, encoding:String.Encoding.utf8)
                return unencryptedMessage
            } else {
                return ""
            }
        }
        return ""
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
    
    func appending(_ key: Key, _ value: Value) -> [Key: Value] {
        var result = self
        result[key] = value
        return result
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

extension UIView{
    func findConstraintByIdentifierName(identifier: String) -> NSLayoutConstraint?{
        return self.constraints.first(where: {$0.identifier == identifier})
    }
}
