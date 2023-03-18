//
//  AuthHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit
import FirebaseAuth

class AuthHelper{
	static func sendOtp(phoneNumber: String, completion: @escaping(_ error: Error?)->()){
		PhoneAuthProvider.provider()
			.verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
				if let error = error {
					completion(error)
					return
				}
				UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
				UserDefaults.standard.set(phoneNumber, forKey: "authPhoneNumber")
				
				completion(nil)
			}
	}
}
