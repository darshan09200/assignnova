//
//  MoreTabVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit
import FirebaseAuth

class MoreTabVC: UIViewController {

	@IBOutlet weak var profileButton: NavigationItem!
	@IBOutlet weak var branchButton: NavigationItem!
	@IBOutlet weak var roleButton: NavigationItem!
	@IBOutlet weak var employeeButton: NavigationItem!
	@IBOutlet weak var paymentButton: NavigationItem!
	
	var employee: Employee?
	override func viewDidLoad() {
        super.viewDidLoad()

		if let employee = ActiveEmployee.instance?.employee{
			self.employee = employee
			profileButton.isHidden = false
			branchButton.isHidden = true
			roleButton.isHidden = true
			employeeButton.isHidden = true
			paymentButton.isHidden = true
			if employee.appRole == .manager || employee.appRole == .shiftSupervisor{
				branchButton.isHidden = false
				roleButton.isHidden = false
				employeeButton.isHidden = false
			} else if employee.appRole == .owner{
				branchButton.isHidden = false
				roleButton.isHidden = false
				employeeButton.isHidden = false
				paymentButton.isHidden = false
			}
		}
    }

	@IBAction func onProfilePress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Employee", bundle: nil).instantiateViewController(withIdentifier: "ViewEmployeeVC") as! ViewEmployeeVC
		viewController.isProfile = true
		viewController.employeeId = ActiveEmployee.instance?.employee.id
		self.navigationController?.pushViewController(viewController, animated: true)
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
			.instantiateViewController(withIdentifier: "ViewAllEmployeeTVC") as! ViewAllEmployeeTVC
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBOutlet weak var onPaymentPress: NavigationItem!
	
	@IBAction func onLogoutPress(_ sender: UIButton) {
		CloudFunctionsHelper.logout()
	}
}
