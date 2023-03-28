//
//  AddRoleVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseFirestore

class AddRoleVC: UIViewController {
	@IBOutlet weak var roleNameInput: TextInput!

	@IBOutlet weak var colorImage: UIImageView!
	@IBOutlet weak var colorLabel: UILabel!

	private var color: Color = ColorPickerVC.colors.first!

	var isEdit: Bool = false
	var role: Role?

	override func viewDidLoad() {
		super.viewDidLoad()

		if isEdit, let role = role{
			navigationItem.title = "Edit Role"
			roleNameInput.textFieldComponent.text = role.name
            roleNameInput.textFieldComponent.textContentType = .name
			if let color = ColorPickerVC.colors.first(where: {$0.color.toHex == role.color}){
				print(color)
				colorLabel.text = color.name
				colorImage.tintColor = color.color
				self.color = color
			}
		}
	}

	@IBAction func onSelectColorPress(_ sender: Any) {
		self.present(ColorPickerVC.getController(delegate: self, selectedColor: color.color),
					 animated:true, completion: nil)
	}


	@IBAction func onCancelButtonPress(_ sender: Any) {
		dismiss(animated: true)
	}

	@IBAction func onSavePress(_ sender: Any) {
		guard let roleName = roleNameInput.textFieldComponent.text, !roleName.isEmpty else {
			showAlert(title: "Oops", message: "Role Name is empty", textInput: roleNameInput)
			return
		}

		var role = Role(
			name: roleName,
			businessId: ActiveEmployee.instance?.business?.id ?? "",
			color: color.color.toHex()!
		)

		role.id = self.role?.id
		if let editRole = self.role{
			role.createdAt = editRole.createdAt
		}

		self.startLoading()
		FirestoreHelper.saveRole(role){ error in
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

extension AddRoleVC: ColorPickerDelegate{
	func onCancelColorPicker() {
		print("cancelled")
	}

	func onSelectColor(color: Color) {
		self.color = color
		colorLabel.text = color.name
		colorImage.tintColor = color.color
	}
}
