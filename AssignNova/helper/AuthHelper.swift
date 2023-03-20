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
	
	static func doesPhoneNumberExists(_ phoneNumber: String, completion: @escaping(_ error: String?)->()){
		let url = URL(string:"https://us-central1-assignnova.cloudfunctions.net/doesPhoneNumberExists")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		do{
			request.httpBody = try JSONSerialization.data(withJSONObject: ["phoneNumber": phoneNumber], options: .prettyPrinted)
		} catch{
			
		}
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			if let error = error {
				completion("Error validating phone number")
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse,
				  (200...299).contains(httpResponse.statusCode) else {
				completion("Error validating phone number")
				return
			}
			
			if let data = data,
			   let accountExistResponse = try? JSONDecoder().decode(AccountExistResponse.self, from: data) {
				if let exists = accountExistResponse.exists{
					if exists{
						completion("Phone number already linked with different account")
					} else {
						completion(nil)
					}
				} else {
					completion(accountExistResponse.error)
				}
				return
			}
			completion("Error validating phone number")
		})
		task.resume()
	}
	
	static func doesEmailExists(_ email: String, completion: @escaping(_ error: String?)->()){
		let url = URL(string:"https://us-central1-assignnova.cloudfunctions.net/doesEmailExists")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		do{
			request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email], options: .prettyPrinted)
		} catch{
			
		}
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			if let error = error {
				completion("Error validating email")
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse,
				  (200...299).contains(httpResponse.statusCode) else {
				completion("Error validating email")
				return
			}
			
			if let data = data,
			   let accountExistResponse = try? JSONDecoder().decode(AccountExistResponse.self, from: data) {
				if let exists = accountExistResponse.exists{
					if exists{
						completion("Email already linked with different account")
					} else {
						completion(nil)
					}
				} else {
					completion(accountExistResponse.error)
				}
				return
			}
			completion("Error validating email")
		})
		task.resume()
	}
	
	static func getErrorMessage(error: Error?) -> String?{
		if error == nil { return nil }
		if let error = error as NSError? {
			let errorCode = AuthErrorCode(_nsError: error).code
			if errorCode == .invalidEmail{
				return "Email is invalid"
			} else if errorCode == .weakPassword{
				return "Password is weak"
			} else if errorCode == .emailAlreadyInUse{
				return "Email is already in use"
			}
		}
		return "Unknown error occured"
	}
}

struct AccountExistResponse: Decodable{
	var exists: Bool?
	var error: String?
}
