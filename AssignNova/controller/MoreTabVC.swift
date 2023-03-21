//
//  MoreTabVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit
import FirebaseAuth

class MoreTabVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	@IBAction func onBranchPress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Branch", bundle: nil)
			.instantiateViewController(withIdentifier: "ViewAllBranchTVC") as! ViewAllBranchTVC
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBAction func onLogoutPress(_ sender: UIButton) {
		let firebaseAuth = Auth.auth()
		do {
			try firebaseAuth.signOut()
		} catch let signOutError as NSError {
			print("Error signing out: %@", signOutError)
		}
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let loginController = storyboard.instantiateViewController(identifier: "LoginNavVC")
		
		(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginController)
	}
}
