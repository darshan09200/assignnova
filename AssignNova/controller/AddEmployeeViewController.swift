//
//  AddEmployeeViewController.swift
//  AssignNova
//
//  Created by simran mehra on 2023-03-19.
//

import UIKit

class AddEmployeeViewController: UIViewController {
    
    @IBOutlet weak var FnameTextInput: TextInput!
    @IBOutlet weak var LnameTextInput: TextInput!
    @IBOutlet weak var EmailTextInput: TextInput!
    @IBOutlet weak var PhoneTextInput: TextInput!
    @IBOutlet weak var EmpIdTextInput: TextInput!
    @IBOutlet weak var RoleTextInput: TextInput!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func AddEmployee(_ sender: UIButton) {
        
        guard let fname = FnameTextInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !fname.isEmpty else {
            showAlert(title: "Oops", message: "First Name is empty", textInput: FnameTextInput)
            return
        }
        guard let lname = LnameTextInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !lname.isEmpty else {
            showAlert(title: "Oops", message: "Last Name is empty", textInput: LnameTextInput)
            return
        }
        guard let email = EmailTextInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            showAlert(title: "Oops", message: "E-mail is required", textInput: EmailTextInput)
            return
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    

