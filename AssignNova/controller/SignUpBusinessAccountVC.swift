//
//  SetupBusinessAccountVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class SignUpBusinessAccountVC: UIViewController {

	
	@IBOutlet weak var firstNameInput: TextInput!
	@IBOutlet weak var lastNameInput: TextInput!
	@IBOutlet weak var emailInput: TextInput!
	@IBOutlet weak var phoneNumberInput: TextInput!
	@IBOutlet weak var pwdInput: TextInput!
	@IBOutlet weak var confirmPwdInput: TextInput!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		phoneNumberInput.textFieldComponent.keyboardType = .phonePad
		
		pwdInput.textFieldComponent.isSecureTextEntry = true
		confirmPwdInput.textFieldComponent.isSecureTextEntry = true
		
		let pwdButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
		pwdButton.tintColor = .label
		pwdButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
		pwdButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
		let pwdBtnView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 30))
		pwdBtnView.addSubview(pwdButton)
		pwdInput.textFieldComponent.rightViewMode = .always
		pwdInput.textFieldComponent.rightView = pwdBtnView
		pwdButton.addTarget(self, action: #selector(togglePassword(_:)), for: .touchUpInside)
		
		let confirmPwdButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
		confirmPwdButton.tintColor = .label
		confirmPwdButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
		confirmPwdButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
		let confirmPwdBtnView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 30))
		confirmPwdBtnView.addSubview(confirmPwdButton)
		confirmPwdInput.textFieldComponent.rightViewMode = .always
		confirmPwdInput.textFieldComponent.rightView = confirmPwdBtnView
		confirmPwdButton.addTarget(self , action: #selector(toggleConfirmPassword(_:)), for: .touchUpInside)
		
    }
	
	@objc func togglePassword(_ sender: UIButton){
		sender.isSelected = !sender.isSelected
		pwdInput.textFieldComponent.isSecureTextEntry = !sender.isSelected
	}
	
	@objc func toggleConfirmPassword(_ sender: UIButton){
		sender.isSelected = !sender.isSelected
		confirmPwdInput.textFieldComponent.isSecureTextEntry = !sender.isSelected
	}
	

	@IBAction func onCreateAccountBtnPress(_ sender: UIButton) {
		guard let firstName = firstNameInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !firstName.isEmpty else {
			showAlert(title: "Oops", message: "First Name is empty", textInput: firstNameInput)
			return
		}
		
		guard let lastName = lastNameInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !lastName.isEmpty else {
			showAlert(title: "Oops", message: "Last Name is empty", textInput: lastNameInput)
			return
		}
		
		guard let email = emailInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
			showAlert(title: "Oops", message: "Email is empty", textInput: emailInput)
			return
		}
		
		guard let phoneNumber = phoneNumberInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !phoneNumber.isEmpty else {
			showAlert(title: "Oops", message: "Phone Number is empty", textInput: phoneNumberInput)
			return
		}
				
		guard let pwd = pwdInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !pwd.isEmpty else {
			showAlert(title: "Oops", message: "Password is empty", textInput: pwdInput)
			return
		}
		
		guard let confirmPwd = confirmPwdInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !confirmPwd.isEmpty else {
			showAlert(title: "Oops", message: "Confirm Password is empty", textInput: confirmPwdInput)
			return
		}
		
		let phoneNumberDetails = ValidationHelper.phoneNumberDetails(phoneNumber)
		
		if !ValidationHelper.isValidEmail(email){
			showAlert(title: "Oops", message: "Email is invalid", textInput: emailInput)
		} else if phoneNumberDetails == nil {
			showAlert(title: "Oops", message: "Phone Number is invalid", textInput: phoneNumberInput)
		} else if let region = phoneNumberDetails?.regionID, region != "US" && region != "CA"{
			if let regionName = ValidationHelper.getRegionName(phoneNumberDetails!){
				showAlert(title: "Oops", message: "\(regionName) is not yet supported", textInput: phoneNumberInput)
			} else {
				showAlert(title: "Oops", message: "Country not supported", textInput: phoneNumberInput)
			}
		} else if email == pwd {
			showAlert(title: "Oops", message: "Email cannot be your password", textInput: pwdInput)
		} else if let pwdError = ValidationHelper.isValidPwd(pwd){
			showAlert(title: "Oops", message: pwdError, textInput: pwdInput)
		} else if confirmPwd != pwd{
			showAlert(title: "Oops", message: "Password and Confirm Password doesn't match", textInput: confirmPwdInput)
		} else {
			let formattedPhoneNumber = ValidationHelper.formatPhoneNumber(phoneNumberDetails!)
			print("\(firstName), \(lastName), \(email), \(formattedPhoneNumber), \(pwd), \(confirmPwd)")
			self.startLoading()
			AuthHelper.doesPhoneNumberExists(formattedPhoneNumber){ error, exists in
				if let error = error {
					self.stopLoading(){
						self.showAlert(title: "Oops", message: error, textInput: self.phoneNumberInput)
					}
				} else if let exists = exists{
					if exists {
						self.showAlert(title: "Oops", message:"Phone number already linked with different account", textInput: self.phoneNumberInput)
						return
					}
					DispatchQueue.main.async {
						(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.preventRefresh = true
					}
					Auth.auth().createUser(withEmail: email, password: pwd) { authResult, error in
						if let error = AuthHelper.getErrorMessage(error: error){
							self.stopLoading(){
								self.showAlert(title: "Oops", message: error, textInput: self.emailInput)
							}
							return
						}
						print("created")
						
						let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
						changeRequest?.displayName = "\(firstName) \(lastName)"
						
						changeRequest?.commitChanges { error in
							if let _ = error {
								self.stopLoading(){
									self.showAlert(title: "Oops", message: "Unknown error occured")
								}
								return
							}
							
							if let uid = Auth.auth().currentUser?.uid
							{
								let employee = Employee(userId: uid, firstName: firstName, lastName: lastName, appRole: .owner, email: email, phoneNumber: phoneNumber)
								FirestoreHelper.saveEmployee(employee){_ in}
							}
							
							Auth.auth().currentUser?.sendEmailVerification { error in
								if let error = error{
									print(error.localizedDescription)
								}
							}
							
							AuthHelper.sendOtp(phoneNumber: formattedPhoneNumber){ error in
								self.stopLoading(){
									let otpInputController = UIStoryboard(name: "OtpInput", bundle: nil)
										.instantiateViewController(withIdentifier: "OtpInputVC") as! OtpInputVC
									
									otpInputController.delegate = self
									self.navigationController?.pushViewController(otpInputController, animated: true)
								}
							}
						}
					}
				}
			}
		}
	}
	
	@IBAction func onSignUpWithGooglePress(_ sender: UIButton) {
		guard let clientID = FirebaseApp.app()?.options.clientID else { return }
		let config = GIDConfiguration(clientID: clientID)
		GIDSignIn.sharedInstance.configuration = config
		
		self.startLoading()
		GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
			if let error = error {
				self.stopLoading(){
					self.showAlert(title: "Oops", message: error.localizedDescription)
				}
				return
			}
			if let user = result?.user,
				  let idToken = user.idToken?.tokenString
			{
				let email = user.profile?.email
				let firstName = user.profile?.givenName
				let lastName = user.profile?.familyName
				AuthHelper.doesEmailExists(email ?? ""){ error, _  in
					if let error = error {
						self.stopLoading(){
							self.showAlert(title: "Oops", message: error)
						}
					} else {
						let credential = GoogleAuthProvider.credential(withIDToken: idToken,
																	   accessToken: user.accessToken.tokenString)
						DispatchQueue.main.async {
							(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.preventRefresh = true
						}
						Auth.auth().signIn(with: credential) { result, error in
							if let error = AuthHelper.getErrorMessage(error: error){
								self.stopLoading(){
									self.showAlert(title: "Oops", message: error)
								}
								return
							}
							if let uid = result?.user.uid{
								let employee = Employee(userId: uid, firstName: firstName ?? "", lastName: lastName ?? "", appRole: .owner, email: email!)
								FirestoreHelper.saveEmployee(employee){ error in
									if let error = error{
										self.showAlert(title: "Oops", message: error.localizedDescription)
										return
									}
//									self.stopLoading(){
//										self.navigateToSetupBusiness()
//									}
									DispatchQueue.main.async {
										(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.refreshData()
									}
								}
							} else {
								self.stopLoading(){
									self.showAlert(title: "Oops", message: "Unknown error occured")
								}
							}
							
						}
					}
				}
			} else {
				self.stopLoading(){
					self.showAlert(title: "Oops", message: "Unknown error occured")
				}
			}
		}
	}
	
}

extension SignUpBusinessAccountVC: OtpInputDelegate{
	func onOtpVerified(credential: PhoneAuthCredential, controller: OtpInputVC) {
		if let user = Auth.auth().currentUser{
			user.link(with: credential){authResult, error in
				if let error = error as NSError? {
					let errorCode = AuthErrorCode(_nsError: error).code
					if errorCode == .accountExistsWithDifferentCredential {
//						self.navigationController?.popViewController(animated: true)
						self.showAlert(title: "Oops", message: "Phone number already linked with different account")
					}
					return
				}
				if let error = error{
					print(error.localizedDescription)
					return
				}
//				self.navigationController?.popViewController(animated: true)
//				self.navigateToSetupBusiness()
				DispatchQueue.main.async {
					(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.refreshData()
				}
			}
		}
	}
	
	func navigateToSetupBusiness(){
		DispatchQueue.main.async {
			let setupBusinessVC = UIStoryboard(name: "SignUpBusiness", bundle: nil)
				.instantiateViewController(withIdentifier: "SetupBusinessVC") as! SetupBusinessVC
			self.navigationController?.pushViewController(setupBusinessVC, animated: true)
		}
	}
}
