//
//  ViewController.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-17.
//

import UIKit
import GoogleMaps
import GooglePlaces
import AEOTPTextField
import FirebaseAuth

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

	}

	@IBAction func onSignInPress(_ sender: Any) {
        navigationController?.pushViewController(UIStoryboard(name: "SignInScreen", bundle: nil).instantiateViewController(withIdentifier: "SignInVC"), animated: true)
	}

	@IBAction func onOpenSignUpBusinessPress(_ sender: Any) {
		let signUpBusinessVC = UIStoryboard(name: "SignUpBusiness", bundle: nil)
			.instantiateViewController(withIdentifier: "SignUpBusinessAccountVC") as! SignUpBusinessAccountVC
		self.navigationController?.pushViewController(signUpBusinessVC, animated: true)
	}
}
