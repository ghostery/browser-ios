//
//  Crypto.swift
//  Client
//
//  Created by Mahmoud Adam on 7/17/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import UIKit
import React


@objc(Crypto)
class Crypto : RCTEventEmitter {
    private let privateKeyTag = "com.connect.cliqz.private"
    private let publicKeyTag = "com.connect.cliqz.public"
    private let blockSizeInBytes = 256
    private let secNoPadding = SecPadding.init(rawValue: 0)
    
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc(generateRandomSeed:reject:)
    func generateRandomSeed(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let length = 128
        if let randomSeed = generateRandomBytes(length) {
            resolve(randomSeed)
        } else {
            reject("RandomNumberGenerationFailure", "Could not generate random seed", nil)
        }
    }
    
    @objc(generateRSAKey:reject:)
    func generateRSAKey(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        
        let privateKeyAttr : [String: Any] = [
            kSecAttrIsPermanent as String: kCFBooleanFalse,
            kSecAttrApplicationTag as String: privateKeyTag
        ]
        
        let publicKeyAttr : [String: Any] = [
            kSecAttrIsPermanent as String: kCFBooleanFalse,
            kSecAttrApplicationTag as String: publicKeyTag
        ]
        
        
        let parameters: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: blockSizeInBytes * 8,
            kSecPrivateKeyAttrs as String : privateKeyAttr,
            kSecPublicKeyAttrs as String: publicKeyAttr
            ]
        
        var publicKey, privateKey: SecKey?
        
        SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)
        var privateKeyData: Data?
        var error:Unmanaged<CFError>?
        
        if #available(iOS 10.0, *) {
            if let cfdata = SecKeyCopyExternalRepresentation(privateKey!, &error) {
                privateKeyData = cfdata as Data
            }
        } else {
            let query: [String:Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                kSecAttrApplicationTag as String: privateKeyTag,
                kSecReturnData as String: kCFBooleanTrue,
            ]
            
            var secureItemValue: AnyObject?
            let statusCode: OSStatus = SecItemCopyMatching(query as CFDictionary, &secureItemValue)
            if let data = secureItemValue as? Data, statusCode == noErr {
                privateKeyData = data
            }
        }
        
        if let data = privateKeyData {
            resolve(data.base64EncodedString())
        } else {
            reject("generateRSAKeyError", "Export privateKey failed.", nil)
        }
    }
    
    
    @objc(encryptRSA:base64PublicKey:resolve:reject:)
    func encryptRSA(base64Data: String, base64PublicKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        
        if let decodedData = Data(base64Encoded: base64Data) ,
            let publicKey = getKey(base64PublicKey, secAttrKeyClass: kSecAttrKeyClassPublic as String, keyTag: publicKeyTag) {
        
            let plainTextData = [UInt8](decodedData)
            let plainTextDataLength = plainTextData.count
            
            var encryptedData = [UInt8](repeating: 0, count: Int(blockSizeInBytes))
            var encryptedDataLength = blockSizeInBytes
            
            let result = SecKeyEncrypt(publicKey, secNoPadding,
                                       plainTextData, plainTextDataLength, &encryptedData, &encryptedDataLength)
            
            if result == noErr {
                let encData = NSData(bytes: encryptedData, length: encryptedDataLength)
                resolve(encData.base64EncodedString())
                return
            }
        }
        reject("EncryptionError", "Could not encrypt data", nil)
    }
    
    @objc(decryptRSA:base64PrivateKey:resolve:reject:)
    func decryptRSA(base64Data: String, base64PrivateKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        
        if let decodedData = Data(base64Encoded: base64Data) ,
            let privateKey = getKey(base64PrivateKey, secAttrKeyClass: kSecAttrKeyClassPrivate as String, keyTag: privateKeyTag) {
            
            let encryptedData = [UInt8](decodedData)
            let encryptedDataLength = encryptedData.count
            
            var decryptedData = [UInt8](repeating: 0, count: Int(blockSizeInBytes))
            var decryptedDataLength = blockSizeInBytes
            
            let result = SecKeyDecrypt(privateKey, secNoPadding,
                                       encryptedData, encryptedDataLength,
                                       &decryptedData, &decryptedDataLength)
            
            if result == noErr {
                let decData = NSData(bytes: decryptedData, length: decryptedDataLength)
                resolve(decData.base64EncodedString())
                return
            }
            
        }
        reject("DecryptionError", "Could not decrypt data", nil)
    }
    
    @objc(signRSA:base64PrivateKey:resolve:reject:)
    func signRSA(base64Data: String, base64PrivateKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        
        if let decodedData = Data(base64Encoded: base64Data) ,
            let privateKey = getKey(base64PrivateKey, secAttrKeyClass: kSecAttrKeyClassPrivate as String, keyTag: privateKeyTag) {
            
            let data = [UInt8](decodedData)
            let dataLength = data.count
            
            var sigData = [UInt8](repeating: 0, count: Int(blockSizeInBytes))
            var sigDataLength = blockSizeInBytes
            
            let result = SecKeyRawSign(privateKey, .PKCS1SHA256,
                                       data, dataLength,
                                       &sigData, &sigDataLength)
            
            if result == noErr {
                let singedData = NSData(bytes: sigData, length: sigDataLength)
                resolve(singedData.base64EncodedString())
                return
            }
            
        }
        reject("SigningError", "Could not sign data", nil)
    }

    
    
    // MARK: - Private helpers
    
    private func generateRandomBytes(_ length: Int) -> String? {
        var keyData = Data(count: length)
		let count = keyData.count
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, count, $0)
        }
        if result == errSecSuccess {
            return keyData.base64EncodedString()
        } else {
            // in case of failure
            var randomString = ""
            for _ in 0..<length {
                let randomNumber = Int(arc4random_uniform(10))
                randomString += String(randomNumber)
            }
            return randomString.data(using: String.Encoding.utf8)?.base64EncodedString()
        }
    }
    
    private func getKey(_ base64Key: String, secAttrKeyClass: String, keyTag: String) -> SecKey? {
        var secKey: SecKey?
        
        guard let secKeyData = Data(base64Encoded: base64Key) else {
            return nil
        }
        
        if #available(iOS 10.0, *) {
            
            let attributes: [String:Any] = [
                kSecAttrKeyClass as String: secAttrKeyClass,
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                kSecAttrKeySizeInBits as String: blockSizeInBytes * 8,
                ]
            secKey = SecKeyCreateWithData(secKeyData as CFData, attributes as CFDictionary, nil)
            
        } else {
            /*
            let query: [String:Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                kSecAttrApplicationTag as String: keyTag,
                kSecReturnPersistentRef as String: kCFBooleanTrue,
                kSecValueData as String : secKeyData
            ]
            
            var persistentRef: AnyObject?
            let status = SecItemAdd(query as CFDictionary, &persistentRef)
            
            if status == noErr || status == errSecDuplicateItem {
                secKey = obtainKey(keyTag)
            }
            */
        }
        return secKey
    }
    /*
    private func obtainKey(_ tag: String) -> SecKey? {
        var keyRef: AnyObject?
        let query: [String:Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: tag,
            kSecReturnRef as String: kCFBooleanTrue,
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, &keyRef)
        if status == noErr, let ref = keyRef {
            
            let deleteQuery: [String:Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: tag
                ]
            SecItemDelete(deleteQuery as CFDictionary)
            return (ref as! SecKey)
        }
        
        return nil
    }
    */
}
