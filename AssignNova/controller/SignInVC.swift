//
//  SignInViewController.swift
//  AssignNova
//
//  Created by PAVIT KALRA on 2023-03-18.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import FirebaseAnalytics

class SignInVC: UIViewController {

    @IBOutlet weak var emailTxt: TextInput!
    @IBOutlet weak var passwordTxt: TextInput!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var loginMethodSegment: UISegmentedControl!
    
	@IBOutlet weak var forgotPwdButton: UIButton!
	
	@IBOutlet weak var phoneNumberTxt: TextInput!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		self.phoneNumberTxt.textFieldComponent.keyboardType = .phonePad
		
		passwordTxt.textFieldComponent.isSecureTextEntry = true
        
        emailTxt.textFieldComponent.textContentType = .emailAddress
        emailTxt.textFieldComponent.keyboardType = .emailAddress
        
        passwordTxt.textFieldComponent.textContentType = .password
		
		let pwdButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
		pwdButton.tintColor = .label
		pwdButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
		pwdButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
		let pwdBtnView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 30))
		pwdBtnView.addSubview(pwdButton)
		passwordTxt.textFieldComponent.rightViewMode = .always
		passwordTxt.textFieldComponent.rightView = pwdBtnView
		pwdButton.addTarget(self, action: #selector(togglePassword(_:)), for: .touchUpInside)
    }
	
	@objc func togglePassword(_ sender: UIButton){
		sender.isSelected = !sender.isSelected
		passwordTxt.textFieldComponent.isSecureTextEntry = !sender.isSelected
	}
    
	@IBAction func loginBtnPressed(_ sender: UIButton) {
		
		if loginMethodSegment.selectedSegmentIndex == 0 {
			
			guard let email = emailTxt.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
				showAlert(title: "Oops", message: "Email is empty", textInput: emailTxt)
				return
			}
			
			guard let pwd = passwordTxt.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !pwd.isEmpty else {
				showAlert(title: "Oops", message: "Password is empty", textInput: passwordTxt)
				return
			}
			
			if !ValidationHelper.isValidEmail(email){
				showAlert(title: "Oops", message: "Email is invalid", textInput: emailTxt)
			} else if let pwdError = ValidationHelper.isValidPwd(pwd){
				showAlert(title: "Oops", message: pwdError, textInput: passwordTxt)
			} else{
				self.startLoading()
				Auth.auth().signIn(withEmail: email, password: pwd) { authResult, error in
					if error != nil {
						self.stopLoading(){
							self.showAlert(title: "Oops", message: "Incorrecnt username or password", textInput: self.emailTxt)
						}
						return
					}
					Analytics.logEvent(AnalyticsEventLogin, parameters: [
						AnalyticsParameterMethod : "email"
					])
//					self.navigateToHome()
				}
			}
		} else if loginMethodSegment.selectedSegmentIndex == 1 {
			guard let phoneNumber = phoneNumberTxt.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !phoneNumber.isEmpty else {
				showAlert(title: "Oops", message: "Phone Number is empty", textInput: phoneNumberTxt)
				return
			}
			
			let phoneNumberDetails = ValidationHelper.phoneNumberDetails(phoneNumber)
			
			if phoneNumberDetails == nil {
				showAlert(title: "Oops", message: "Phone Number is invalid", textInput: phoneNumberTxt)
			} else{
				self.startLoading()
				let formattedPhoneNumber = ValidationHelper.formatPhoneNumber(phoneNumberDetails!)
				CloudFunctionsHelper.doesPhoneNumberExists(formattedPhoneNumber){ error, exists  in
					if let error = error {
						self.stopLoading(){
							self.showAlert(title: "Oops", message: error, textInput: self.phoneNumberTxt)
						}
					} else if let exists = exists, exists {
						CloudFunctionsHelper.sendOtp(phoneNumber: formattedPhoneNumber){ error in
							self.stopLoading(){
								let otpInputController = UIStoryboard(name: "OtpInput", bundle: nil)
									.instantiateViewController(withIdentifier: "OtpInputVC") as! OtpInputVC
								
								otpInputController.delegate = self
								self.navigationController?.pushViewController(otpInputController, animated: true)
							}
						}
					} else {
						self.stopLoading(){
							self.showAlert(title: "Oops", message: "Phone number not linked with any account", textInput: self.phoneNumberTxt)
						}
					}
				}
			}
		}
		
	}
    
    @IBAction func googleLoginBtnPressed(_ sender: UIButton) {
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
				CloudFunctionsHelper.doesEmailExists(email ?? ""){ error, exists  in
					if let exists = exists{
						if exists{
							let credential = GoogleAuthProvider.credential(withIDToken: idToken,
																		   accessToken: user.accessToken.tokenString)
							Auth.auth().signIn(with: credential) { result, error in
								if let error = CloudFunctionsHelper.getErrorMessage(error: error){
									self.stopLoading(){
										self.showAlert(title: "Oops", message: error)
									}
									return
								}
								Analytics.logEvent(AnalyticsEventLogin, parameters: [
									AnalyticsParameterMethod : "google"
								])
//								self.navigateToHome()
							}
						} else {
							self.stopLoading(){
								self.showAlert(title: "Oops", message: "Account doesnt exists")
							}
						}
					} else if let error = error {
						self.stopLoading(){
							self.showAlert(title: "Oops", message: error)
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
    
    @IBAction func loginModeChanged(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
			case 0:
				self.forgotPwdButton.isHidden = false
				UIView.animate(withDuration: 0.3) {
					self.emailTxt.isHidden = false
					self.passwordTxt.isHidden = false
					
					self.phoneNumberTxt.isHidden = true
				}
			case 1:
				self.forgotPwdButton.isHidden = true
				UIView.animate(withDuration: 0.3) {
					self.emailTxt.isHidden = true
					self.passwordTxt.isHidden = true
					
					self.phoneNumberTxt.isHidden = false
				}
			default:
				break
		}
    }
    
	@IBAction func onForgotPasswordBtnPressed(_ sender: Any) {
		let viewController = UIStoryboard(name: "Password", bundle: nil)
			.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}

extension SignInVC: OtpInputDelegate{
	func onOtpVerified(credential: PhoneAuthCredential, controller: OtpInputVC) {
		Auth.auth().signIn(with: credential){authResult, error in
			if let _ = error {
				self.showAlert(title: "Oops", message: "Unknown error occured.")
				return
			}
			Analytics.logEvent(AnalyticsEventLogin, parameters: [
				AnalyticsParameterMethod : "phone"
			])
		}
	}
	
}
