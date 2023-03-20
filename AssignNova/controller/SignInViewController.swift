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

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTxt: TextInput!
    @IBOutlet weak var passwordTxt: TextInput!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var loginMethodSegment: UISegmentedControl!
    
    @IBOutlet weak var phoneNumberTxt: TextInput!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
      
        if loginMethodSegment.selectedSegmentIndex == 0 {
            
            guard let email = emailTxt.textFieldComponent.text, !email.isEmpty else {
                // Show an error message to the user and prevent login
                showAlert(title: "Error", message: "Please enter your email address.")
                return
            }
            
            guard let password = passwordTxt.textFieldComponent.text, !password.isEmpty else {
                // Show an error message to the user and prevent login
                showAlert(title: "Error", message: "Please enter your password.")
                return
            }
            
            // Add authentication logic here. For example, you can check if the email and password are valid by calling a backend API or querying a local database.
            let isEmailValid = isEmailValid(email)
            let isPasswordValid = isPasswordValid(password)
            
            if !isEmailValid {
                // Show an error message to the user and prevent login
                showAlert(title: "Error", message: "Please enter a valid email address.")
                return
            }
            
            if !isPasswordValid {
                // Determine why the password is invalid and show a message to the user
                var errorMessage = "Please enter a valid password."
                if password.count < 8 {
                    errorMessage += " Password must be at least 8 characters long."
                }
                showAlert(title: "Error", message: errorMessage)
                return
            }
            
            // All validations passed, so allow login to proceed
            // Your code for successful login goes here
            
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    // An error occurred while attempting to sign in the user
                    strongSelf.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                // The user was signed in successfully
                // You can perform any necessary tasks after the user has signed in here
                
            }
        } else if loginMethodSegment.selectedSegmentIndex == 1 {
            // Phone number validation
                    guard let phoneNumber = phoneNumberTxt.textFieldComponent.text, !phoneNumber.isEmpty else {
                        // Show an error message to the user and prevent login
                        showAlert(title: "Error", message: "Please enter your phone number.")
                        return
                    }
                    
                    // Add phone number validation logic here. For example, you can check if the phone number is valid by using a regular expression.
                    let isPhoneNumberValid = isPhoneNumberValid(phoneNumber)
                    
                    if !isPhoneNumberValid {
                        // Show an error message to the user and prevent login
                        showAlert(title: "Error", message: "Please enter a valid phone number.")
                        return
                    }
                    
                    // All validations passed, so allow login to proceed
                    // Your code for successful login goes here
                    
                    // You can authenticate the user using Firebase Authentication's phone number authentication method.
                    // See https://firebase.google.com/docs/auth/ios/phone-auth for more information.
            }
        
        }
    
    @IBAction func googleLoginBtnPressed(_ sender: UIButton) {
        print("Hello")
    }
    
    
    func isPhoneNumberValid(_ phoneNumber: String) -> Bool {
        let phoneRegex = #"^\d{10}$"#
        let phonePredicate = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    func isEmailValid(_ email: String) -> Bool {
        // Use regular expressions to validate the email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        // Check if the password is at least 8 characters long
        if password.count < 8 {
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
    
    @IBAction func loginModeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                UIView.animate(withDuration: 0.3) {
                    self.emailTxt.isHidden = false
                   
                    self.passwordTxt.isHidden = false
                    
                    self.phoneNumberTxt.isHidden = true
                    
                    self.googleLoginBtn.isHidden = false
                    
                    self.loginBtn.setTitle("Login", for: .normal)
                }
            case 1:
                UIView.animate(withDuration: 0.3) {
                    self.emailTxt.isHidden = true
                    
                    self.passwordTxt.isHidden = true
                    
                    self.phoneNumberTxt.isHidden = false
                    
                    self.phoneNumberTxt.textFieldComponent.keyboardType = .phonePad
                    
                    self.googleLoginBtn.isHidden = true
                    
                    self.loginBtn.setTitle("Send OTP", for: .normal)
                   
                }
            default:
                break
            }
    }
    
}
