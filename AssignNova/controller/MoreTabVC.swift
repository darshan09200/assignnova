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
	
	@IBAction func onRolePress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Role", bundle: nil)
			.instantiateViewController(withIdentifier: "ViewAllRoleTVC") as! ViewAllRoleTVC
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBAction func onEmployeePress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Employee", bundle: nil)
			.instantiateViewController(withIdentifier: "AddEmployeeTVC") as! AddEmployeeTVC
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
	
	@IBAction func onLogoutPress(_ sender: UIButton) {
		AuthHelper.logout()
	}
}
