//
//  Keychain.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-12.
//

import Security
import UIKit

class Keychain {
	static let accessGroup = "L9Z24WLH63.com.techtoids.assignnova.shared"
	
	class func save(key: String, data: Data) -> OSStatus {
		let query = [
			kSecClass as String       : kSecClassGenericPassword as String,
			kSecAttrAccount as String : key,
			kSecAttrAccessGroup as String: accessGroup,
			kSecValueData as String   : data ] as [String : Any]
		
		SecItemDelete(query as CFDictionary)
		
		return SecItemAdd(query as CFDictionary, nil)
	}
	
	class func delete(key: String) -> OSStatus {
		let query = [
			kSecClass as String       : kSecClassGenericPassword as String,
			kSecAttrAccessGroup as String: accessGroup,
			kSecAttrAccount as String : key ] as [String : Any]
		
		return SecItemDelete(query as CFDictionary)
	}
	
	class func load(key: String) -> Data? {
		let query = [
			kSecClass as String       : kSecClassGenericPassword,
			kSecAttrAccount as String : key,
			kSecReturnData as String  : kCFBooleanTrue!,
			kSecAttrAccessGroup as String: accessGroup,
			kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
		
		var dataTypeRef: AnyObject? = nil
		
		let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
		
		if status == noErr {
			return dataTypeRef as? Data
		} else {
			return nil
		}
	}
	
	class func createUniqueID() -> String {
		let uuid: CFUUID = CFUUIDCreate(nil)
		let cfStr: CFString = CFUUIDCreateString(nil, uuid)
		
		let swiftString: String = cfStr as String
		return swiftString
	}
}

extension Data {
	
	init(from value: String) {
		var value = value
		self.init(value.utf8)
	}
	
	func to(type: String.Type) -> String? {
		return String(data: self, encoding: .utf8)
	}
}
