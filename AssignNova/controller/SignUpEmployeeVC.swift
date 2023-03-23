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

    @IBOutlet weak var SignUpModeSegment: UISegmentedControl!
    @IBOutlet weak var input: TextInput!
    @IBOutlet weak var checkForInviteBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
	
	let loadingVC = LoadingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		
		loadingVC.modalPresentationStyle = .overCurrentContext
		loadingVC.modalTransitionStyle = .crossDissolve
    }
    
    @IBAction func checkForInviteBtnPressed(_ sender: UIButton) {
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
    
	@IBAction func onAuthMethodChange(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
			case 0:
				input.label = "Email"
				input.textFieldComponent.keyboardType = .default
			case 1:
				input.label = "Phone Number"
				input.textFieldComponent.keyboardType = .phonePad
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


extension SignUpEmployeeVC{
	
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
