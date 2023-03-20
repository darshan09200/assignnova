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

class SignInVC: UIViewController {

    @IBOutlet weak var emailTxt: TextInput!
    @IBOutlet weak var passwordTxt: TextInput!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var loginMethodSegment: UISegmentedControl!
    
    @IBOutlet weak var phoneNumberTxt: TextInput!
	
	let loadingVC = LoadingViewController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		self.phoneNumberTxt.textFieldComponent.keyboardType = .phonePad
		
		passwordTxt.textFieldComponent.isSecureTextEntry = true
		
		let pwdButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
		pwdButton.tintColor = .label
		pwdButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
		pwdButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
		let pwdBtnView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 30))
		pwdBtnView.addSubview(pwdButton)
		passwordTxt.textFieldComponent.rightViewMode = .always
		passwordTxt.textFieldComponent.rightView = pwdBtnView
		pwdButton.addTarget(self, action: #selector(togglePassword(_:)), for: .touchUpInside)
		
		loadingVC.modalPresentationStyle = .overCurrentContext
		loadingVC.modalTransitionStyle = .crossDissolve
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.navigationBar.prefersLargeTitles = false
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
					if let error = error {
						// An error occurred while attempting to sign in the user
						self.showAlert(title: "Error", message: error.localizedDescription)
						return
					}
					self.navigateToHome()
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
				let firstName = user.profile?.givenName
				let lastName = user.profile?.familyName
				AuthHelper.doesEmailExists(email ?? ""){ error, exists  in
					if let exists = exists{
						if exists{
							let credential = GoogleAuthProvider.credential(withIDToken: idToken,
																		   accessToken: user.accessToken.tokenString)
							Auth.auth().signIn(with: credential) { result, error in
								if let error = AuthHelper.getErrorMessage(error: error){
									self.stopLoading(){
										self.showAlert(title: "Oops", message: error)
									}
									return
								}
								
								self.navigateToHome()
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
    
	func showAlert(title: String, message: String, textInput: TextInput? = nil){
		print("\(title): \(message)")
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
			if let textInput = textInput{
				DispatchQueue.main.async {
					textInput.textFieldComponent.becomeFirstResponder()
				}
			}
		}))
		self.present(alert, animated: true, completion: nil)
		
	}
    
    @IBAction func loginModeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                UIView.animate(withDuration: 0.3) {
                    self.emailTxt.isHidden = false
					self.passwordTxt.isHidden = false
                    
                    self.phoneNumberTxt.isHidden = true
                }
            case 1:
                UIView.animate(withDuration: 0.3) {
                    self.emailTxt.isHidden = true
                    self.passwordTxt.isHidden = true
					
                    self.phoneNumberTxt.isHidden = false
                }
            default:
                break
            }
    }
    
}

extension SignInVC: OtpInputDelegate{
	func onOtpVerified(credential: PhoneAuthCredential, controller: UIViewController) {
		Auth.auth().signIn(with: credential){authResult, error in
			if let _ = error {
				self.showAlert(title: "Oops", message: "Unknown error occured.")
				return
			}
			self.navigateToHome()
		}
	}
	
	func navigateToHome(){
		DispatchQueue.main.async {
			let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
			let mainTabBarController = storyboard.instantiateViewController(identifier: "HomeNavVC")
			
			(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
		}
	}
}


extension SignInVC{
	
	func startLoading(){
		DispatchQueue.main.async {
			self.present(self.loadingVC, animated: true, completion: nil)
		}
	}
	
	func stopLoading(completion: (() -> Void)? = nil){
		DispatchQueue.main.async {
			if self.loadingVC.isModal{
				self.loadingVC.dismiss(animated: true, completion: completion)
			} else if let completion = completion {
				completion()
			}
		}
	}
}
