//
//  SignUpEmployeeViewController.swift
//  AssignNova
//
//  Created by PAVIT KALRA on 2023-03-18.
//

import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

class SignUpEmployeeVC: UIViewController {

    @IBOutlet weak var modeSegment: UISegmentedControl!
    @IBOutlet weak var textInput: TextInput!
    @IBOutlet weak var checkForInviteBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
	
	let loadingVC = LoadingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		
		loadingVC.modalPresentationStyle = .overCurrentContext
		loadingVC.modalTransitionStyle = .crossDissolve
        
        textInput.textFieldComponent.textContentType = .emailAddress;
        textInput.textFieldComponent.keyboardType = .emailAddress
    }
    
    @IBAction func checkForInviteBtnPressed(_ sender: UIButton) {
		guard let inputText = textInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !inputText.isEmpty else {
			showAlert(title: "Oops", message: "\(modeSegment.selectedSegmentIndex == 0 ? "Email" : "Phone Number") is empty", textInput: textInput)
			return
		}
		
		if modeSegment.selectedSegmentIndex == 0{
			self.startLoading()
			AuthHelper.isUserInvited(email: inputText){error, invited in
				if let error = error{
					self.stopLoading(){
						self.showAlert(title: "Oops", message: error)
					}
					return
				}
				self.stopLoading(){
					let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SetupEmployeeVC") as! SetupEmployeeVC
					viewController.email = inputText
					self.navigationController?.pushViewController(viewController, animated: true)
				}
			}
		} else {
			let phoneNumberDetails = ValidationHelper.phoneNumberDetails(inputText)
			if phoneNumberDetails == nil {
				showAlert(title: "Oops", message: "Phone Number is invalid", textInput: textInput)
			} else if let region = phoneNumberDetails?.regionID, region != "US" && region != "CA"{
				if let regionName = ValidationHelper.getRegionName(phoneNumberDetails!){
					showAlert(title: "Oops", message: "\(regionName) is not yet supported", textInput: textInput)
				} else {
					showAlert(title: "Oops", message: "Country not supported", textInput: textInput)
				}
			} else {
				self.startLoading()
				let formattedPhoneNumber = ValidationHelper.formatPhoneNumber(phoneNumberDetails!)
				AuthHelper.isUserInvited(phoneNumber: formattedPhoneNumber){error, invited in
					if let error = error{
						self.stopLoading(){
							self.showAlert(title: "Oops", message: error)
						}
						return
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
    
    @IBAction func continueWithGoogleBtnPressed(_ sender: UIButton) {
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
				AuthHelper.isUserInvited(email: email){error, invited in
					if let error = error{
						self.stopLoading(){
							self.showAlert(title: "Oops", message: error)
						}
						return
					}
					
					let credential = GoogleAuthProvider.credential(withIDToken: idToken,
																   accessToken: user.accessToken.tokenString)
					
					DispatchQueue.main.async {
						(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.preventRefresh = true
					}
					Auth.auth().signIn(with: credential) { result, error in
						if let error = error{
							self.stopLoading(){
								self.showAlert(title: "Oops", message: "Unknown error occured")
							}
							return
						}
					}
					AuthHelper.isUserRegistered(email: email){error, registered in
						DispatchQueue.main.async {
							(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.refreshData()
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
    
	@IBAction func onAuthModeChanged(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
			case 0:
				textInput.label = "Email"
				textInput.textFieldComponent.textContentType = .emailAddress;
				textInput.textFieldComponent.keyboardType = .emailAddress
			case 1:
				textInput.label = "Phone Number"
				textInput.textFieldComponent.keyboardType = .phonePad
				textInput.textFieldComponent.textContentType = .telephoneNumber
			default:
				break
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
}

extension SignUpEmployeeVC: OtpInputDelegate{
	func onOtpVerified(credential: PhoneAuthCredential, controller: OtpInputVC) {
		DispatchQueue.main.async {
			(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.preventRefresh = true
		}
		
		Auth.auth().signIn(with: credential) { result, error in
			if error != nil {
				self.stopLoading(){
					self.showAlert(title: "Oops", message: "Unknown error occured")
				}
				return
			}
			AuthHelper.isUserRegistered(phoneNumber: controller.phoneNumber){error, registered in
				DispatchQueue.main.async {
					(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.refreshData()
				}
			}
		}
		
	}
}
