//
//  SetupBusinessVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit
import GooglePlaces
import FirebaseFirestore
import FirebaseAuth

class SetupBusinessVC: UIViewController {

	@IBOutlet weak var businessNameInput: TextInput!

	@IBOutlet weak var selectLocationLabel: UILabel!

	@IBOutlet weak var numberOfEmployeeInput: TextInput!

	@IBOutlet weak var smallPlanCard: PlanCard!
	@IBOutlet weak var businessPlanCard: PlanCard!
	@IBOutlet weak var enterprisePlanCard: PlanCard!

	let minusButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
	let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))

	var place: GMSPlace?

	var showLogout = false


	let loadingVC = LoadingViewController()


	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		numberOfEmployeeInput.textFieldComponent.text = "10"
		numberOfEmployeeInput.textFieldComponent.delegate = self
		numberOfEmployeeInput.textFieldComponent.keyboardType = .numberPad


		minusButton.tintColor = .label
		minusButton.setImage(UIImage(systemName: "minus"), for: .normal)
		let minusBtnView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 30))
		minusBtnView.addSubview(minusButton)
		numberOfEmployeeInput.textFieldComponent.leftViewMode = .always
		numberOfEmployeeInput.textFieldComponent.leftView = minusBtnView
		minusButton.addTarget(self, action: #selector(onMinusPress(_:)), for: .touchUpInside)
		minusButton.isEnabled = false

		addButton.tintColor = .label
		addButton.setImage(UIImage(systemName: "plus"), for: .normal)
		let addBtnView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 30))
		addBtnView.addSubview(addButton)
		numberOfEmployeeInput.textFieldComponent.rightViewMode = .always
		numberOfEmployeeInput.textFieldComponent.rightView = addBtnView
		addButton.addTarget(self, action: #selector(onAddPress(_:)), for: .touchUpInside)

		if showLogout{
			let logout = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(onLogoutPress))
			navigationItem.rightBarButtonItem = logout
		}
	}

	@objc func onLogoutPress(){
		AuthHelper.logout()
	}

	@IBAction func onSelectLocationButonPress(_ sender: Any) {
		self.present(SelectLocationVC.getController(delegate: self),
					 animated:true, completion: nil)
	}

	@objc func onMinusPress(_ sender: UIButton){
		guard let count = Int(numberOfEmployeeInput.textFieldComponent.text!), count > 10 else {
			return
		}
		let newCount = 10 * Int(count / 10) - 10
		if newCount <= 10 { minusButton.isEnabled = false }
		numberOfEmployeeInput.textFieldComponent.text = String(newCount)
		refreshPlans()
	}

	@objc func onAddPress(_ sender: UIButton){
		guard let count = Int(numberOfEmployeeInput.textFieldComponent.text!) else { return }
		let newCount = 10 * Int(count / 10) + 10
		minusButton.isEnabled = true
		numberOfEmployeeInput.textFieldComponent.text = String(newCount)
		refreshPlans()
	}

	func refreshPlans(){
		guard let count = Int(numberOfEmployeeInput.textFieldComponent.text!) else { return }
		let formattedCount = 10 * Int(count / 10)
		smallPlanCard.isSelected = false
		businessPlanCard.isSelected = false
		enterprisePlanCard.isSelected = false
		if formattedCount < 51{
			smallPlanCard.isSelected = true
		} else if formattedCount  < 201{
			businessPlanCard.isSelected = true
		} else {
			enterprisePlanCard.isSelected = true
		}
	}


	@IBAction func onMakePaymentBtnPress(_ sender: UIButton) {
		guard let businessName = businessNameInput.textFieldComponent.text, !businessName.isEmpty else {
			showAlert(title: "Oops", message: "Business name is empty", textInput: businessNameInput)
			return
		}
		guard let selectedPlace = place else {
			showAlert(title: "Oops", message: "Location for business is not selected")
			return
		}
		guard let numberOfEmployees = numberOfEmployeeInput.textFieldComponent.text, !numberOfEmployees.isEmpty else {
			showAlert(title: "Oops", message: "Number of Employees is empty", textInput: businessNameInput)
			return
		}
		guard let noOfEmpCount = Int(numberOfEmployees), noOfEmpCount % 10 == 0 else {
			showAlert(title: "Oops", message: "Number of Employees is invalid. It can only be in groups of 10", textInput: businessNameInput)
			return
		}

		let userId = ActiveEmployee.instance?.employee.id ?? Auth.auth().currentUser!.uid
		let business = Business(name: businessName, address: selectedPlace.formattedAddress ?? "", noOfEmployees: noOfEmpCount, location: GeoPoint(latitude: selectedPlace.coordinate.latitude, longitude: selectedPlace.coordinate.longitude), managedBy: userId)
		self.startLoading()
		FirestoreHelper.saveBusiness(business){ error in
			if let error = error{
				if let error = error as NSError?{
					let errorCode = FirestoreErrorCode(_nsError: error).code
					if errorCode == .permissionDenied{
						self.stopLoading(){
							self.showAlert(title: "Oops", message: "Seems like you are not logged in. Login to setup business"){
								self.navigationController?.popToRootViewController(animated: true)
							}
						}
						return
					}
					self.stopLoading(){
						self.showAlert(title: "Oops", message: "Unknown error occured")
					}
				}
				print(error.localizedDescription)
				return
			}
			DispatchQueue.main.async {
				AuthHelper.refreshData()

				let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
				let mainTabBarController = storyboard.instantiateViewController(identifier: "HomeNavVC")

				(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
			}

		}
	}
}

extension SetupBusinessVC: UITextFieldDelegate{
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let count = Int(textField.text!), count % 10 != 0 else { return }
		let newCount = 10 * Int(count / 10)
		textField.text = String(newCount)
		refreshPlans()
	}
}

extension SetupBusinessVC: SelectLocationDelegate{
	func onSelectLocation(place: GMSPlace) {
		self.place = place
		if let text = businessNameInput.textFieldComponent.text{
			if text.isEmpty{
				businessNameInput.textFieldComponent.text = place.name
			}
		}
		selectLocationLabel.text = place.formattedAddress
		selectLocationLabel.textColor = .label
	}

	func onCancelLocation() {
		print("cancelled")
	}

}
