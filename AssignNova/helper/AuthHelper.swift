//
//  AuthHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit
import FirebaseAuth
import FirebaseFunctions

class AuthHelper{
	static var userId: String?{
		return Auth.auth().currentUser?.uid
	}

	static func refreshData(completion: ((_ activeEmployee: ActiveEmployee?)->())? = nil){
		FirestoreHelper.getEmployee(userId: userId ?? ""){ employee in
			if let employee = employee{
				var activeEmployee = ActiveEmployee(employee: employee)
				FirestoreHelper.getBusiness(employeeId: employee.id ?? "" ){ business in
					if let business = business, let _ = business.id{
						activeEmployee.business = business
						ActiveEmployee.instance = activeEmployee
					} else {
						ActiveEmployee.instance = activeEmployee
					}
					if let completion = completion{
						completion(ActiveEmployee.instance)
					}
				}
			} else {
				ActiveEmployee.instance = nil
				if let completion = completion{
					completion(ActiveEmployee.instance)
				}
			}
		}
	}
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
	
	static func call(apiName: String, with data: Any)-> URLRequest{
		let url = URL(string:"https://us-central1-assignnova.cloudfunctions.net/\(apiName)")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		do{
			request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
		} catch{}

		return request
	}

	static func doesPhoneNumberExists(_ phoneNumber: String, completion: @escaping(_ error: String?)->()){
		let request = call(apiName: "doesPhoneNumberExists", with: ["phoneNumber": phoneNumber])

		let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			if error != nil {
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

	static func doesEmailExists(_ email: String, completion: @escaping(_ error: String?, _ exists: Bool? )->()){
		let request = call(apiName: "doesEmailExists", with: ["email": email])
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			if let _ = error {
				completion("Error validating email", nil)
				return
			}

			guard let httpResponse = response as? HTTPURLResponse,
				  (200...299).contains(httpResponse.statusCode) else {
				completion("Error validating email", nil)
				return
			}

			if let data = data,
			   let accountExistResponse = try? JSONDecoder().decode(AccountExistResponse.self, from: data) {
				if let exists = accountExistResponse.exists{
					if exists {
						completion("Email already linked with different account", true)
					} else {
						completion(nil, false)
					}
				} else {
					completion(accountExistResponse.error, nil)
				}
				return
			}
			completion("Error validating email", nil)
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

	static func isUserInvited(email: String? = nil, phoneNumber: String? = nil, completion: @escaping(_ error: String?, _ invited: Bool? )->()){
		
		var data = [String: String]()
		if let email = email{
			data["email"] = email
		}
		if let phoneNumber = phoneNumber{
			data["phoneNumber"] = phoneNumber
		}
		print(data)
		
		let request = call(apiName: "isUserInvited", with: data)
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			if let error = error {
				print(error.localizedDescription)
				completion("Error validating invite", nil)
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse,
				  (200...299).contains(httpResponse.statusCode) else {
				completion("Error validating invite", nil)
				return
			}
			
			if let data = data,
			   let userInvitedResponse = try? JSONDecoder().decode(UserInvitedResponse.self, from: data) {
				if let invited = userInvitedResponse.invited, invited{
					completion(nil, false)
				} else {
					completion(userInvitedResponse.error, nil)
				}
				return
			}
			completion("Error validating invite", nil)
		})
		task.resume()
	}
	
	static func isUserRegistered(email: String? = nil, phoneNumber: String? = nil, count: Int = 1, completion: @escaping(_ error: String?, _ registered: Bool? )->()){
		
		var data = [String: String]()
		if let email = email{
			data["email"] = email
		}
		if let phoneNumber = phoneNumber{
			data["phoneNumber"] = phoneNumber
		}
		
		print(data)
		
		Functions.functions().httpsCallable("checkIfUserRegistered").call(data){
			result, error in
			if let error = error {
				print(error.localizedDescription)
				completion("Error signing in", nil)
				return
			}
			
			if let data = result?.data as? [String: Any]{
				if let registered = data["registered"] as? Bool, registered{
					completion(nil, true)
				} else if count < 3{
					let deadline = DispatchTime.now() + 1 + DispatchTimeInterval.seconds(count)
					print(deadline)
					DispatchQueue.main.asyncAfter(deadline: deadline)
					{
						isUserRegistered(email: email, phoneNumber: phoneNumber, count: count + 1, completion: completion)
					}
				} else {
					completion("Error signing in", nil)
				}
				return
			}
			completion("Error signing in", nil)
		}
	}
	
	static func logout(){
		do {
			try Auth.auth().signOut()
		} catch let signOutError as NSError {
			print("Error signing out: %@", signOutError)
		}
	}
}

struct AccountExistResponse: Decodable{
	var exists: Bool?
	var error: String?
}

struct UserInvitedResponse: Decodable{
	var invited: Bool?
	var error: String?
}
