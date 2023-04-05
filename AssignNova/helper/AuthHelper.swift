//
//  AuthHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit
import FirebaseAuth
import FirebaseFunctions
import FirebaseSharedSwift

class AuthHelper{
	static var userId: String?{
		return Auth.auth().currentUser?.uid
	}

    static func refreshData(completion: ((_ activeEmployee: ActiveEmployee?)->())? = nil){
        if let currentUser = Auth.auth().currentUser{
            currentUser.getIDToken(){ token, error in
                print(error?.localizedDescription)
                if error == nil{
                    FirestoreHelper.getEmployee(userId: userId ?? ""){ employee in
                        if let employee = employee{
                            let activeEmployee = ActiveEmployee(employee: employee)
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
                } else{
                    ActiveEmployee.instance = nil
                    if let completion = completion{
                        completion(ActiveEmployee.instance)
                    }
                }
            }
        } else {
            ActiveEmployee.instance = nil
            if let completion = completion{
                completion(ActiveEmployee.instance)
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

	static func doesPhoneNumberExists(_ phoneNumber: String, completion: @escaping(_ error: String?, _ exists: Bool?)->()){
		let request = call(apiName: "doesPhoneNumberExists", with: ["phoneNumber": phoneNumber])

		let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			if error != nil {
				completion("Error validating phone number", nil)
				return
			}

			guard let httpResponse = response as? HTTPURLResponse,
				  (200...299).contains(httpResponse.statusCode) else {
				completion("Error validating phone number", nil)
				return
			}

			if let data = data,
			   let accountExistResponse = try? JSONDecoder().decode(AccountExistResponse.self, from: data) {
				if let exists = accountExistResponse.exists{
					if exists{
						completion(nil, true)
					} else {
						completion(nil, false)
					}
				} else {
					completion(accountExistResponse.error, nil)
				}
				return
			}
			completion("Error validating phone number", nil)
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
		FirestoreHelper.deregisterFCMToken()
		do {
			try Auth.auth().signOut()
		} catch let signOutError as NSError {
			print("Error signing out: %@", signOutError)
		}
	}
	
	static func getEligibleEmployees(branchId: String?, roleId: String?, shiftDate: Date, startTime: Date, endTime: Date, completion: @escaping(_ groupedEmployees: [GroupedEmployee]? )->()){
//		Functions.functions().useEmulator(withHost: "127.0.0.1", port: 5001)
		
		var data = EligibleEmployeesRequest(
			shiftDate:  Date.combineDateWithTime(date: shiftDate, time: startTime).timeIntervalSince1970,
			startTime: Date.combineDateWithTime(date: shiftDate, time: startTime).timeIntervalSince1970,
			endTime: Date.combineDateWithTime(date: shiftDate, time: endTime).timeIntervalSince1970)
		let employee = ActiveEmployee.instance?.employee
		if let businessId = employee?.businessId{
			data.businessId = businessId
		}
		if let branchId = branchId{
			data.branchId = branchId
		}
		if let roleId = roleId{
			data.roleId = roleId
		}
		let callable: Callable<EligibleEmployeesRequest, GroupedEmployees> = Functions.functions().httpsCallable("getEligibleEmployees")
		callable.call(data){result in
			if let groupedEmployees = try? result.get() {
				completion(groupedEmployees.groupedEmployees)
				return
			}
			completion(nil)
		}
	}
	
	static func getAssignedHours(employeeIds: [String], shiftDate: Date, completion: @escaping(_ assignedHours: [AssignedHour]? )->()){
		if employeeIds.count == 0 {
			completion([])
			return
		}
		let callable: Callable<AssignedHoursRequest, AssignedHoursResponse> = Functions.functions().httpsCallable("getAssignedHours")
		callable.call(AssignedHoursRequest(employeeIds: employeeIds, shiftDate: shiftDate.startOfDay.timeIntervalSince1970)){ result in
			if let assignedHours = try? result.get(){
				completion(assignedHours.assignedHours)
				return
			}
			completion(nil)
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

enum EmployeeEligibility: String, Decodable{
	case notEligible = "Not Eligible"
	case notConfirmed = "Not Confirmed"
	case eligible = "Eligible"
}

struct GroupedEmployee: Decodable{
	var type: EmployeeEligibility
	var employees: [String]
}

struct GroupedEmployees: Decodable{
	var groupedEmployees: [GroupedEmployee]
}

struct EligibleEmployeesRequest:Codable{
	var businessId: String?
	var branchId: String?
	var roleId: String?
	var shiftDate: TimeInterval
	var startTime: TimeInterval
	var endTime: TimeInterval
}

struct AssignedHoursRequest: Codable{
	var employeeIds: [String]
	var shiftDate: TimeInterval
}

struct AssignedHoursResponse: Codable{
	var assignedHours: [AssignedHour]
	
}

struct AssignedHour: Codable{
	var employeeId: String
	var assignedHour: Double
}

