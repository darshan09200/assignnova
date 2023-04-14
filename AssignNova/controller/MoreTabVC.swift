//
//  MoreTabVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit
import FirebaseAuth

class MoreTabVC: UIViewController {

	@IBOutlet weak var employeeNameLabel: UILabel!
	@IBOutlet weak var businessNameLabel: UILabel!
	
	@IBOutlet weak var profileButton: NavigationItem!
	@IBOutlet weak var branchButton: NavigationItem!
	@IBOutlet weak var roleButton: NavigationItem!
	@IBOutlet weak var employeeButton: NavigationItem!
	@IBOutlet weak var paymentButton: NavigationItem!
	
	@IBOutlet weak var changePasswordButton: NavigationItem!
	
	@IBOutlet weak var logoutButton: NavigationItem!
	
	var employee: Employee?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		logoutButton.labelComponent.textColor = .systemRed
		logoutButton.imageView.tintColor = .systemRed
		logoutButton.rightImageComponent.isHidden = true
		
		if let employee = ActiveEmployee.instance?.employee{
			self.employee = employee
			employeeNameLabel.text = employee.name
			businessNameLabel.text = ActiveEmployee.instance?.business?.name ?? "Business"
			roleButton.isHidden = true
			employeeButton.isHidden = true
			paymentButton.isHidden = true
			if employee.appRole == .manager || employee.appRole == .shiftSupervisor{
				roleButton.isHidden = false
				employeeButton.isHidden = false
			} else if employee.appRole == .owner{
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
	
	
	@IBAction func onBusinessPress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Business", bundle: nil)
			.instantiateViewController(withIdentifier: "ViewBusinessVC") as! ViewBusinessVC
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
	
	@IBAction func onAvailabilityPress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Availability", bundle: nil)
			.instantiateViewController(withIdentifier: "ViewAllAvailabilityVC") as! ViewAllAvailabilityVC
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBAction func onPaymentPress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Payment", bundle: nil)
			.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBAction func onChangePasswordPress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Password", bundle: nil)
			.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBAction func onLogoutPress(_ sender: Any) {
		CloudFunctionsHelper.logout()
	}
}
