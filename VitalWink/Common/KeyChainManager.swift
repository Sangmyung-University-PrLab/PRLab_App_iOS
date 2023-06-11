//
//  KeyChainManager.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/18.
//

import Foundation
import Dependencies

final class KeyChainManager{
    func getBaseQuery(key: String) -> [CFString: Any]{
        return [kSecClass: kSecClassGenericPassword,
          kSecAttrService: Bundle.main.bundleIdentifier!,
          kSecAttrAccount: key]
    }
    
    func deleteInKeyChain(key: String) -> Bool{
        let query = getBaseQuery(key: key)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == noErr else{
            return false
        }
        
        return true
    }
    
    func saveInKeyChain(key: String, data: String) -> Bool{
        var query = getBaseQuery(key: key)
        let encodedDate = data.data(using: .utf8)!
        let status: OSStatus
        
        if let _ = readInKeyChain(key: key){
            status = SecItemUpdate(query as CFDictionary, [kSecValueData: encodedDate] as CFDictionary)
        }else{
            query[kSecValueData] = encodedDate
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        guard status == noErr else{
            return false
        }
        
        return true
    }
    
    func readInKeyChain(key: String) -> String?{
        var query = getBaseQuery(key: key)
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnAttributes] = kCFBooleanTrue
        query[kSecReturnData] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult){
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else{
            return nil
        }
        guard status == noErr else{
            return nil
        }
        
        guard let existingItem = queryResult as? [String: AnyObject],
              let data = existingItem[kSecValueData as String] as? Data,
              let dataString = String(data: data, encoding: .utf8) else{
            return nil
        }
        
        return dataString
    }
    
    func saveTokenInKeyChain(_ token: String) -> Bool{
        saveInKeyChain(key: Key.token.rawValue, data: token)
    }
    
    func readTokenInKeyChain() -> String?{
        return readInKeyChain(key: Key.token.rawValue)
    }
    
    func deleteTokenInKeyChain() -> Bool{
        return deleteInKeyChain(key: Key.token.rawValue)
    }
    
    private enum Key: String{
        case token = "token"
    }
}

extension KeyChainManager: DependencyKey{
    static var liveValue: KeyChainManager = KeyChainManager()
}
