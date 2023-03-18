//
//  SignUpEmployeeSetupViewController.swift
//  AssignNova
//
//  Created by PAVIT KALRA on 2023-03-18.
//

import UIKit

class SignUpEmployeeSetupViewController: UIViewController {

    @IBOutlet weak var emailTxt: TextInput!
    @IBOutlet weak var passwordTxt: TextInput!
    @IBOutlet weak var confirmPasswordTxt: TextInput!
    
    @IBOutlet weak var completeSetupBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func completeSetupBtnPressed(_ sender: UIButton) {
        guard let password = passwordTxt.textFieldComponent.text, !password.isEmpty else {
                showAlert(title: "Error", message: "Please enter your password.")
                return
            }
                   
            guard let confirmPassword = confirmPasswordTxt.textFieldComponent.text, !confirmPassword.isEmpty else {
                showAlert(title: "Error", message: "Please confirm your password.")
                return
            }
                   
            let isPasswordValid = isPasswordValid(password)
            if !isPasswordValid {
                var errorMessage = "Please enter a valid password."
                if password.count < 8 {
                    errorMessage += " Password must be at least 8 characters long."
                }
                if !password.contains(where: { $0.isUppercase }) {
                    errorMessage += " Password must contain at least one uppercase letter."
                }
                if !password.contains(where: { $0.isNumber }) {
                    errorMessage += " Password must contain at least one digit."
                }
                showAlert(title: "Error", message: errorMessage)
                return
            }
                   
            guard password == confirmPassword else {
                showAlert(title: "Error", message: "Passwords do not match.")
                return
            }
                   
            // Add code to create a new employee account using the email and password fields
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
