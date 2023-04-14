//
//  EditBusinessVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit
import GooglePlaces
import FirebaseFirestore
import FirebaseAuth
import StripePaymentSheet

class EditBusinessVC: UIViewController {

	@IBOutlet weak var businessNameInput: TextInput!

	@IBOutlet weak var selectLocationLabel: UILabel!
	@IBOutlet weak var selectLocationView: UIView!
	@IBOutlet var selectLocationGesture: UITapGestureRecognizer!
	
	@IBOutlet weak var numberOfEmployeeInput: TextInput!

	@IBOutlet weak var smallPlanCard: PlanCard!
	@IBOutlet weak var businessPlanCard: PlanCard!
	@IBOutlet weak var enterprisePlanCard: PlanCard!
	
	@IBOutlet weak var makePaymentButton: UIButton!
	
	var businessReference: DocumentReference?

	let minusButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
	let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))

	var place: GMSPlace?

	var paymentDetails: PaymentDetails?
	var business: Business?
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		if let business = business{
			businessNameInput.textFieldComponent.text = business.name
			selectLocationLabel.text = business.address
			selectLocationLabel.textColor = .label
			numberOfEmployeeInput.textFieldComponent.text = String(business.noOfEmployees)
			
		} else {
			numberOfEmployeeInput.textFieldComponent.text = "5"
		}
		numberOfEmployeeInput.textFieldComponent.delegate = self
		numberOfEmployeeInput.textFieldComponent.keyboardType = .numberPad

        businessNameInput.textFieldComponent.textContentType = .name

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

		numberOfEmployeeInput.textFieldComponent.addTarget(self, action: #selector(onNumberOfEmployeeChange), for: .editingChanged)
		
		refreshPlans()
	}

	
	@objc func onNumberOfEmployeeChange(){
		refreshPlans()
	}

	
	@objc func onLogoutPress(){
		CloudFunctionsHelper.logout()
	}

	@IBAction func onSelectLocationButonPress(_ sender: Any) {
		self.present(SelectLocationVC.getController(delegate: self),
					 animated:true, completion: nil)
	}

	@objc func onMinusPress(_ sender: UIButton){
		view.endEditing(false)
		guard let count = Int(numberOfEmployeeInput.textFieldComponent.text!), count > 5 else {
			return
		}
		let newCount = count - 1
		if newCount <= 5 { minusButton.isEnabled = false }
		numberOfEmployeeInput.textFieldComponent.text = String(newCount)
		refreshPlans()
	}

	@objc func onAddPress(_ sender: UIButton){
		view.endEditing(false)
		guard let count = Int(numberOfEmployeeInput.textFieldComponent.text!) else { return }
		let newCount = count + 1
		minusButton.isEnabled = true
		numberOfEmployeeInput.textFieldComponent.text = String(newCount)
		refreshPlans()
	}

	func refreshPlans(){
		guard let count = Int(numberOfEmployeeInput.textFieldComponent.text!) else { return }
		smallPlanCard.isSelected = false
		businessPlanCard.isSelected = false
		enterprisePlanCard.isSelected = false
		if count < 51{
			smallPlanCard.isSelected = true
		} else if count  < 201{
			smallPlanCard.isSelected = true
			businessPlanCard.isSelected = true
		} else {
			smallPlanCard.isSelected = true
			businessPlanCard.isSelected = true
			enterprisePlanCard.isSelected = true
		}
		
		var price = 0.0
		if count < 51 {
			price = Double(count) * 4
		} else if count < 251 {
			price = 50 * 4 + (Double(count) - 50) * 3.8
		} else {
			price = 50 * 4 + 150 * 3.8 + (Double(count) - 150) * 3.6
		}
		
		makePaymentButton.setTitle("New Cost - $\(String(format: "%.2f", price))", for: .normal)
	}


	@IBAction func onMakePaymentBtnPress(_ sender: UIButton) {
		
	}
	
	@IBAction func onSavePress(_ sender: Any) {
		guard let businessName = businessNameInput.textFieldComponent.text, !businessName.isEmpty else {
			showAlert(title: "Oops", message: "Business name is empty", textInput: businessNameInput)
			return
		}
		
		guard let numberOfEmployees = numberOfEmployeeInput.textFieldComponent.text, !numberOfEmployees.isEmpty else {
			showAlert(title: "Oops", message: "Number of Employees is empty", textInput: businessNameInput)
			return
		}
		guard let noOfEmpCount = Int(numberOfEmployees) else {
			showAlert(title: "Oops", message: "Number of Employees is invalid", textInput: businessNameInput)
			return
		}
		
		var business = Business(id: business?.id, name: businessName, address: place == nil ? business!.address : place!.formattedAddress ?? "", noOfEmployees: noOfEmpCount, location: place == nil ? business!.location: GeoPoint(latitude: place!.coordinate.latitude, longitude: place!.coordinate.longitude), createdAt: business?.createdAt)
		if let managedBy = self.business?.managedBy{
			business.managedBy = managedBy
		}
		business.subscriptionId = self.business?.subscriptionId
		self.startLoading()
		FirestoreHelper.editBusiness(business){ error in
			if let error = error{
				self.stopLoading(){
					self.showAlert(title: "Oops", message: "Unknown error occured")
				}
				return
			}
			self.stopLoading(){
				self.dismiss(animated: true)
			}
		}
		
	}
	
	@IBAction func onCancelPress(_ sender: Any) {
		self.dismiss(animated: true)
	}
	
}

extension EditBusinessVC: UITextFieldDelegate{
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let count = Int(textField.text!), count < 5 else {
			refreshPlans()
			return
		}
		let newCount = 5
		textField.text = String(newCount)
		refreshPlans()
	}
}

extension EditBusinessVC: SelectLocationDelegate{
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

extension EditBusinessVC{
	
	func getPaymentDetails(_ business: Business, completion: @escaping(_ paymentDetails: PaymentDetails? )->()){
		if let paymentDetails = self.paymentDetails{
			completion(paymentDetails)
		} else {
			CloudFunctionsHelper.updateSubscription(business: business){ paymentDetails in
				self.paymentDetails = paymentDetails
				completion(self.paymentDetails)
			}
		}
	}
	
	func authorizePayment(_ business: Business){
		getPaymentDetails(business){ paymentDetails in
			PaymentHelper.authorizePayment(controller: self, paymentDetails: paymentDetails){paymentResult in
				DispatchQueue.main.async {
					(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.refreshData()
				}
			}
		}
	}
}
