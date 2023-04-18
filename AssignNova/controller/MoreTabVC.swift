//
//  MoreTabVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit
import FirebaseAuth
import IntentsUI
import SafariServices

class MoreTabVC: UIViewController {

	@IBOutlet weak var appStack: UIStackView!
	@IBOutlet weak var employeeNameLabel: UILabel!
	@IBOutlet weak var businessNameLabel: UILabel!
	
	@IBOutlet weak var profileButton: NavigationItem!
	@IBOutlet weak var branchButton: NavigationItem!
	@IBOutlet weak var roleButton: NavigationItem!
	@IBOutlet weak var employeeButton: NavigationItem!
	@IBOutlet weak var paymentButton: NavigationItem!
	
	@IBOutlet weak var changePasswordButton: NavigationItem!
	
	@IBOutlet weak var logoutButton: NavigationItem!
	
	public var intent: MyShiftIntent {
		let testIntent = MyShiftIntent()
		testIntent.suggestedInvocationPhrase = "Show My Shifts"
		return testIntent
	}
	
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
		
		let button = INUIAddVoiceShortcutButton(style: .automaticOutline)
		button.shortcut = INShortcut(intent: intent )
		button.delegate = self
		
		appStack.addArrangedSubview(button)
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
	
	@IBAction func onAboutAppPress(_ sender: Any) {
		let viewController = UIStoryboard(name: "AboutApp", bundle: nil)
			.instantiateViewController(withIdentifier: "AboutAppVC") as! AboutAppVC
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBAction func onSupportPress(_ sender: Any){
		let vc = SFSafariViewController(url: URL(string: "https://help-assignnova.web.app/submit-a-ticket")!)
		vc.delegate = self
		
		self.present(vc, animated: true)
	}
}

extension MoreTabVC: INUIAddVoiceShortcutButtonDelegate {
	func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
		addVoiceShortcutViewController.delegate = self
		addVoiceShortcutViewController.modalPresentationStyle = .formSheet
		present(addVoiceShortcutViewController, animated: true, completion: nil)
	}
	
	func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
		editVoiceShortcutViewController.delegate = self
		editVoiceShortcutViewController.modalPresentationStyle = .formSheet
		present(editVoiceShortcutViewController, animated: true, completion: nil)
	}
	
	
}

extension MoreTabVC: INUIAddVoiceShortcutViewControllerDelegate {
	func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	
}

extension MoreTabVC: INUIEditVoiceShortcutViewControllerDelegate {
	func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}


extension MoreTabVC: SFSafariViewControllerDelegate{
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		dismiss(animated: true)
	}
}
