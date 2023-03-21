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
			businessId: ActiveUser.instance?.business?.id ?? "",
			color: color.color.toHex()!
		)
		
		role.id = self.role?.id
		if let editRole = self.role{
			role.createdAt = editRole.createdAt
		}
		
		self.startLoading()
		FirestoreHelper.saveRole(role){ error in
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
