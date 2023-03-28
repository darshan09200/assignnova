//
//  AddBranchVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit
import GooglePlaces
import FirebaseFirestore

class AddBranchVC: UIViewController {

	@IBOutlet weak var branchNameInput: TextInput!

	@IBOutlet weak var selectLocationLabel: UILabel!

	@IBOutlet weak var colorImage: UIImageView!
	@IBOutlet weak var colorLabel: UILabel!

	private var place: GMSPlace?
	private var color: Color = ColorPickerVC.colors.first!

	var isEdit: Bool = false
	var branch: Branch?

	override func viewDidLoad() {
        super.viewDidLoad()

		if isEdit, let branch = branch{
			navigationItem.title = "Edit Branch"
			branchNameInput.textFieldComponent.text = branch.name
            branchNameInput.textFieldComponent.textContentType = .name
			selectLocationLabel.text = branch.address
			selectLocationLabel.textColor = .label
			if let color = ColorPickerVC.colors.first(where: {$0.color.toHex == branch.color}){
				print(color)
				colorLabel.text = color.name
				colorImage.tintColor = color.color
				self.color = color
			} else {
				print(branch.color)
				print(ColorPickerVC.colors.compactMap{$0.color.toHex})
			}
		}
    }

	@IBAction func onSelectLocationButonPress(_ sender: Any) {
		self.present(SelectLocationVC.getController(delegate: self),
					 animated:true, completion: nil)
	}

	@IBAction func onSelectColorPress(_ sender: Any) {
		self.present(ColorPickerVC.getController(delegate: self, selectedColor: color.color),
					 animated:true, completion: nil)
	}


	@IBAction func onCancelButtonPress(_ sender: Any) {
		dismiss(animated: true)
	}

	@IBAction func onSavePress(_ sender: Any) {
		guard let branchName = branchNameInput.textFieldComponent.text, !branchName.isEmpty else {
			showAlert(title: "Oops", message: "Branch Name is empty", textInput: branchNameInput)
			return
		}

		let location: GeoPoint
		let address: String

		if let selectedPlace = place {
			location =  GeoPoint(latitude: selectedPlace.coordinate.latitude, longitude: selectedPlace.coordinate.longitude)
			address = selectedPlace.formattedAddress ?? ""
		} else if isEdit, let branch = branch{
			location = branch.location
			address = branch.address
		} else {
			showAlert(title: "Oops", message: "Location for branch is not selected")
			return
		}


		var branch = Branch(
			name: branchName,
			address: address,
			location: location,
			businessId: ActiveEmployee.instance?.business?.id ?? "",
			color: color.color.toHex()!
		)

		branch.id = self.branch?.id
		if let editBranch = self.branch{
			branch.createdAt = editBranch.createdAt
		}

		self.startLoading()
		FirestoreHelper.saveBranch(branch){ error in
			if let _ = error{
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
}

extension AddBranchVC: SelectLocationDelegate{
	func onSelectLocation(place: GMSPlace) {
		self.place = place
		if let text = branchNameInput.textFieldComponent.text{
			if text.isEmpty{
				branchNameInput.textFieldComponent.text = place.name
			}
		}
		selectLocationLabel.text = place.formattedAddress
		selectLocationLabel.textColor = .label
	}

	func onCancelLocation() {
		print("cancelled")
	}

}


extension AddBranchVC: ColorPickerDelegate{
	func onCancelColorPicker() {
		print("cancelled")
	}

	func onSelectColor(color: Color) {
		self.color = color
		colorLabel.text = color.name
		colorImage.tintColor = color.color
	}
}
