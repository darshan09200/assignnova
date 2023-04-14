//
//  ResetPasswordVC.swift
//  AssignNova
//
//  Created by PAVIT KALRA on 2023-03-18.
//

import UIKit
import FirebaseAuth

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var emailTxt: TextInput!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
    }
    
	@IBAction func changePasswordBtnPressed(_ sender: UIButton) {
		guard let email = emailTxt.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
			showAlert(title: "Oops", message: "Email is empty", textInput: emailTxt)
			return
		}
		
		if !ValidationHelper.isValidEmail(email){
			showAlert(title: "Oops", message: "Email is invalid", textInput: emailTxt)
		} else {
			self.startLoading()
			Auth.auth().sendPasswordReset(withEmail: email) { error  in
				self.stopLoading(){
					self.showAlert(title: "Done", message: "If an account exists with the given email you will receive a reset password link on the email."){
						self.navigationController?.popViewController(animated: true)
					}
				}
			}
			
		}
	}
}
