//
//  SetupEmployeeVC.swift
//  AssignNova
//
//  Created by PAVIT KALRA on 2023-03-18.
//

import UIKit
import FirebaseAuth

class SetupEmployeeVC: UIViewController {

    @IBOutlet weak var emailTxt: TextInput!
    @IBOutlet weak var passwordTxt: TextInput!
    @IBOutlet weak var confirmPasswordTxt: TextInput!
	
	var email: String?
    
    @IBOutlet weak var completeSetupBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		emailTxt.textFieldComponent.text = email
		emailTxt.textFieldComponent.isEnabled = false
		
		passwordTxt.textFieldComponent.isSecureTextEntry = true
		confirmPasswordTxt.textFieldComponent.isSecureTextEntry = true
		
		let pwdButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
		pwdButton.tintColor = .label
		pwdButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
		pwdButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
		let pwdBtnView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 30))
		pwdBtnView.addSubview(pwdButton)
		passwordTxt.textFieldComponent.rightViewMode = .always
		passwordTxt.textFieldComponent.rightView = pwdBtnView
		pwdButton.addTarget(self, action: #selector(togglePassword(_:)), for: .touchUpInside)
		
		let confirmPwdButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
		confirmPwdButton.tintColor = .label
		confirmPwdButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
		confirmPwdButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
		let confirmPwdBtnView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 30))
		confirmPwdBtnView.addSubview(confirmPwdButton)
		confirmPasswordTxt.textFieldComponent.rightViewMode = .always
		confirmPasswordTxt.textFieldComponent.rightView = confirmPwdBtnView
		confirmPwdButton.addTarget(self , action: #selector(toggleConfirmPassword(_:)), for: .touchUpInside)
    }
	
	@objc func togglePassword(_ sender: UIButton){
		sender.isSelected = !sender.isSelected
		passwordTxt.textFieldComponent.isSecureTextEntry = !sender.isSelected
	}
	
	@objc func toggleConfirmPassword(_ sender: UIButton){
		sender.isSelected = !sender.isSelected
		confirmPasswordTxt.textFieldComponent.isSecureTextEntry = !sender.isSelected
	}
    
	@IBAction func completeSetupBtnPressed(_ sender: UIButton) {
		guard let password = passwordTxt.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty else {
			showAlert(title: "Oops", message: "Password is empty", textInput: passwordTxt)
			return
		}
		
		guard let confirmPassword = confirmPasswordTxt.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !confirmPassword.isEmpty else {
			showAlert(title: "Oops", message: "Confirm Password is empty", textInput: confirmPasswordTxt)
			return
		}
		
		if let pwdError = ValidationHelper.isValidPwd(password){
			showAlert(title: "Oops", message: pwdError, textInput: passwordTxt)
		} else if confirmPassword != password{
			showAlert(title: "Oops", message: "Password and Confirm Password doesn't match", textInput: confirmPasswordTxt)
		} else {
			self.startLoading()
			DispatchQueue.main.async {
				(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.preventRefresh = true
			}
			
			Auth.auth().createUser(withEmail: email!, password: password) { result, error in
				if error != nil {
					self.stopLoading(){
						self.showAlert(title: "Oops", message: "Unknown error occured")
					}
					return
				}
				AuthHelper.isUserRegistered(email: self.email){error, registered in
					DispatchQueue.main.async {
						(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.refreshData()
					}
				}
			}
		}
	}
    
    func isPasswordValid(_ password: String) -> Bool {
        // Check if the password is at least 8 characters long
        if password.count < 8 {
            return false
        }
        
        // Check if the password contains at least one uppercase letter and one digit
        let uppercaseRegex = ".*[A-Z]+.*"
        let uppercasePredicate = NSPredicate(format:"SELF MATCHES %@", uppercaseRegex)
        let digitRegex = ".*[0-9]+.*"
        let digitPredicate = NSPredicate(format:"SELF MATCHES %@", digitRegex)
        if !uppercasePredicate.evaluate(with: password) || !digitPredicate.evaluate(with: password) {
            return false
        }
        
        // All validation checks passed, so the password is valid
        return true
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}
