//
//  UIViewController+Alert.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit

extension UIViewController{
	func showAlert(title: String, message: String, textInput: TextInput? = nil, completion: (() -> Void)? = nil){
		print("\(title): \(message)")
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
			if let textInput = textInput{
				DispatchQueue.main.async {
					textInput.textFieldComponent.becomeFirstResponder()
				}
			} else if let completion = completion{
				completion()
			}
		}))
		self.present(alert, animated: true, completion: nil)
	}
}
