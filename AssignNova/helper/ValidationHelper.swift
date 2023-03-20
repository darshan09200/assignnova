//
//  ValidationHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-19.
//

import UIKit
import PhoneNumberKit


class ValidationHelper{
	static func isValidEmail(_ email: String) -> Bool {
		let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
		
		let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailPred.evaluate(with: email)
	}
	
	static func isValidPwd(_ pwd: String) -> String? {
		
		let pwdRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&#])[A-Za-z\\d@$!%*?&#]{8,}$"

		if pwd.count < 8 {return "Password should be minimum 8 in length" }
		
		let lowerCaseRegex = ".*[a-z]+.*"
		let lowerCasePred = NSPredicate(format:"SELF MATCHES %@", lowerCaseRegex)

		if !lowerCasePred.evaluate(with: pwd){ return "Add atleast one lowercase charachter" }
		
		let upperCaseRegex = ".*[A-Z]+.*"
		let upperCasePred = NSPredicate(format:"SELF MATCHES %@", upperCaseRegex)
		if !upperCasePred.evaluate(with: pwd){ return "Add atleast one uppercase charachter" }
		
		let digitsRegex = ".*[\\d]+.*"
		let digitsPred = NSPredicate(format:"SELF MATCHES %@", digitsRegex)
		if !digitsPred.evaluate(with: pwd){ return "Add atleast one digit" }
		
		let specialCharRegex = ".*[@$!%*?&#]+.*"
		let specialCharPred = NSPredicate(format:"SELF MATCHES %@", specialCharRegex)
		if !specialCharPred.evaluate(with: pwd){ return "Add atleast one special charachter from \"@$!%*?&#\"" }
		
		return nil
	}
	
	static func phoneNumberDetails(_ phoneNumber: String) -> PhoneNumber?{
		let phoneNumberKit = PhoneNumberKit()
		do{
			return try phoneNumberKit.parse(phoneNumber)
		}
		catch{
			return nil
		}
	}
	
	static func formatPhoneNumber(_ phoneNumberDetails: PhoneNumber) -> String{
		let phoneNumberKit = PhoneNumberKit()
		return phoneNumberKit.format(phoneNumberDetails, toType: .e164)
	}
	
	static func getRegionName(_ phoneNumberDetails: PhoneNumber) -> String? {
		if let region = phoneNumberDetails.regionID {
			return Locale.current.localizedString(forRegionCode: region)
		}
		return nil
	}
}
