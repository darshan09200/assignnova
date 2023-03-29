//
//  AddEmployeeTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit
import LetterAvatarKit
import FirebaseFirestore

struct AddEmployeeModel{
	var branches = [Branch]()
	var roles = [Role]()
}

class AddEmployeeTVC: UITableViewController {
	
	var data = AddEmployeeModel()
	
	var isBranchEmpty: Bool{
		ActiveEmployee.instance!.branches.count == 0
	}
	
	var shouldShowAddBranch: Bool{
		data.branches.count < ActiveEmployee.instance!.branches.count
	}
	
	var isRoleEmpty: Bool{
		ActiveEmployee.instance!.roles.count == 0
	}
	
	var shouldShowAddRole: Bool{
		data.roles.count < ActiveEmployee.instance!.roles.count
	}
	
	var isEdit: Bool = false
	var employee: Employee?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.sectionHeaderTopPadding = 0
		tableView.contentInset.bottom = 16
		
		if isEdit, let employee = employee{
			
			navigationItem.title = "Edit Branch"
//
//			if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? InputFieldCell{
//				cell.inputField.textFieldComponent.text = employee.firstName
//			}
//
//			if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? InputFieldCell{
//				cell.inputField.textFieldComponent.text = employee.lastName
//			}
//
//			if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as? InputFieldCell{
//				cell.inputField.textFieldComponent.text = employee.email
//			}
//
//			if let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 1)) as? InputFieldCell{
//				cell.inputField.textFieldComponent.text = employee.phoneNumber
//			}
//
//			if let cell = tableView.cellForRow(at: IndexPath(row: 4, section: 1)) as? InputFieldCell{
//				cell.inputField.textFieldComponent.text = employee.employeeId
//			}
		}
	}
	
	@IBAction func onCancelPress(_ sender: Any) {
		dismiss(animated: true)
	}
	
	@IBAction func onSavePress(_ sender: Any) {
		guard let firstNameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? InputFieldCell,
			  let firstName = firstNameCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines),
				!firstName.isEmpty
		else {
			showAlert(title: "Oops", message: "First Name is empty",
					  textInput: (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputFieldCell).inputField)
			return
		}
		
		guard let lastNameCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? InputFieldCell,
			  let lastName = lastNameCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines),
			  !lastName.isEmpty
		else {
			showAlert(title: "Oops", message: "Last Name is empty",
					  textInput: (tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputFieldCell).inputField)
			return
		}
		
		guard let emailCell = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as? InputFieldCell,
			  let email = emailCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines),
			  !email.isEmpty
		else {
			showAlert(title: "Oops", message: "Email is empty",
					  textInput: (tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! InputFieldCell).inputField)
			return
		}
		
		var phoneNumber: String?
		if let phoneNumberCell = tableView.cellForRow(at: IndexPath(row: 3, section: 1)) as? InputFieldCell{
			phoneNumber  = phoneNumberCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines)
		} else {
			phoneNumber = nil
		}
		
		let employeeId: String?
		if let employeeIdCell = tableView.cellForRow(at: IndexPath(row: 4, section: 1)) as? InputFieldCell{
			employeeId  = employeeIdCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines)
		} else {
			employeeId = nil
		}
		
		let role: AppRole
		if let roleCell = tableView.cellForRow(at: IndexPath(row: 5, section: 1)) as? SelectFieldCell{
			let roleIndex = roleCell.picker?.selectedRow(inComponent: 0) ?? 0
			role = AppRole.allCases[roleIndex]
		} else {
			role = .employee
		}
		
		guard let hoursCell = tableView.cellForRow(at: IndexPath(row: 6, section: 1)) as? InputFieldCell,
			  let hours = hoursCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines),
			  !hours.isEmpty
		else {
			showAlert(title: "Oops", message: "Max Hours is empty")
			return
		}
		
		guard let maxHours = Double(hours) else {
			showAlert(title: "Oops", message: "Max Hours in invalid")
			return
		}
		
		if !ValidationHelper.isValidEmail(email){
			showAlert(title: "Oops", message: "Email is invalid", textInput: emailCell.inputField)
			return
		} else if let nestedPhoneNumber = phoneNumber, !nestedPhoneNumber.isEmpty{
			if let phoneNumberDetails = ValidationHelper.phoneNumberDetails(nestedPhoneNumber){
				if let region = phoneNumberDetails.regionID, region != "US" && region != "CA" {
					let phoneNumberCell = tableView.cellForRow(at: IndexPath(row: 3, section: 1)) as! InputFieldCell
					if let regionName = ValidationHelper.getRegionName(phoneNumberDetails){
						showAlert(title: "Oops", message: "\(regionName) is not yet supported", textInput: phoneNumberCell.inputField)
					} else {
						showAlert(title: "Oops", message: "Country not supported", textInput: phoneNumberCell.inputField)
					}
					return
				} else {
					let formattedPhoneNumber = ValidationHelper.formatPhoneNumber(phoneNumberDetails)
					phoneNumber = formattedPhoneNumber
				}
			} else {
				let phoneNumberCell = tableView.cellForRow(at: IndexPath(row: 3, section: 1)) as! InputFieldCell
				showAlert(title: "Oops", message: "Phone Number is invalid", textInput: phoneNumberCell.inputField)
				return
			}
		}
		
		self.startLoading()
		FirestoreHelper.doesEmployeeExist(email: email, phoneNumber: phoneNumber, employeeId: employee?.id){ existingEmployee in
			if let existingEmployee = existingEmployee {
				self.stopLoading(){
					var message = " already linked with another employee: \(existingEmployee.firstName) \(existingEmployee.lastName)"
					if existingEmployee.phoneNumber == phoneNumber{
						message = "Phone Number"+message
					} else {
						message = "Email"+message
					}
					self.showAlert(title: "Oops", message: message )
				}
			} else {
				let (_, backgroundColor) = UIImage.makeLetterAvatar(withName: "\(firstName) \(lastName)", backgroundColor: UIColor(hex: self.employee?.color ?? ""))
				let employee = Employee(
					id: self.employee?.id,
					userId: self.employee?.userId,
					employeeId: employeeId,
					firstName: firstName,
					lastName: lastName,
					appRole: role,
					maxHours: maxHours,
					isProfilePrivate: self.employee?.isProfilePrivate ?? false,
					email: email,
					phoneNumber: phoneNumber,
					invited: self.employee?.invited ?? true,
					branches: self.data.branches.compactMap{$0.id},
					roles: self.data.roles.compactMap{$0.id},
					color: backgroundColor.toHex ?? "")
				FirestoreHelper.saveEmployee(employee){error in
					if let _ = error {
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
		
	}
}

extension AddEmployeeTVC{

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {return 7}
		if section == 2 {
			return data.branches.count + (shouldShowAddBranch ? 1 : 0) + (isBranchEmpty ? 1 : 0)
		}
		if section == 3 {
			return data.roles.count + ( shouldShowAddRole ? 1 : 0) + (isRoleEmpty ? 1 : 0)
		}
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0{
			let cell = tableView.dequeueReusableCell(withIdentifier: "avatar", for: indexPath) as! AvatarCell
			
			if let firstNameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? InputFieldCell,
				  let firstName = firstNameCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines),
				  !firstName.isEmpty,
			   let lastNameCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? InputFieldCell,
				  let lastName = lastNameCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines),
			   !lastName.isEmpty{
				let (image, _) = UIImage.makeLetterAvatar(withName: "\(firstName) \(lastName)")
				cell.profileImage.image = image
			} else {
				let (image, _) = UIImage.makeLetterAvatar(withName: "John Doe")
				cell.profileImage.image = image
			}
			
			cell.addImageButton?.addTarget(self, action: #selector(onSelectImagePress), for: .touchUpInside)
			
			return cell
		} else if indexPath.section == 1{
			var label: String = ""
			var placeholder: String = ""
			var defaultValue: String? = nil
			switch indexPath.row {
				case 0:
					label = "First Name"
					placeholder = "John"
					defaultValue = employee?.firstName
				case 1:
					label = "Last Name"
					placeholder = "Doe"
					defaultValue = employee?.lastName
				case 2:
					label = "Email"
					placeholder = "abc@xyz.com"
					defaultValue = employee?.email
				case 3:
					label = "Phone Number (Optional)"
					placeholder = "+12345678901"
					defaultValue = employee?.phoneNumber
				case 4:
					label = "Employee Id (Optional)"
					defaultValue = employee?.employeeId
				case 5:
					label = "Role"
				case 6:
					label = "Max Hours/Week"
					defaultValue = String(format: "%.2f", employee?.maxHours ?? 40)
				default: break
			}
			if indexPath.row == 5{
				let cell = tableView.dequeueReusableCell(withIdentifier: "selectForm", for: indexPath) as! SelectFieldCell
				cell.picker?.delegate = self
				cell.picker?.dataSource = self
				cell.label.text = label
				cell.selectButton.setTitle((employee?.appRole ?? AppRole.employee).rawValue, for: .normal)
				cell.picker?.selectRow((employee?.appRole ?? AppRole.employee).index ?? 0, inComponent: 0, animated: true)
				return cell
			}
			let cell = tableView.dequeueReusableCell(withIdentifier: "inputForm", for: indexPath) as! InputFieldCell
			cell.inputField.label = label
			cell.inputField.placeholder = placeholder
			cell.inputField.textFieldComponent.text = defaultValue
			
			if indexPath.row == 0 || indexPath.row == 1{
				cell.inputField.textFieldComponent.addTarget(self, action: #selector(nameDidChange(_:)), for: .editingChanged)
			}
			
			return cell
		} else {
			let isLast: Bool
			let isEmpty: Bool
			let addCardLabel: String
			let selector: Selector
			var title: String?
			var subtitle: String?
			var barColor: String?
			if indexPath.section == 2{
				isLast = data.branches.endIndex  == indexPath.row && shouldShowAddBranch
				isEmpty = isBranchEmpty
				addCardLabel = "Branch"
				selector = #selector(onAddBranchPress)
				if !isLast && !isEmpty{
					title = data.branches[indexPath.row].name
					subtitle = data.branches[indexPath.row].address
					barColor = data.branches[indexPath.row].color
				}
			} else {
				isLast = data.roles.endIndex  == indexPath.row && shouldShowAddRole
				isEmpty = isRoleEmpty
				addCardLabel = "Role"
				selector = #selector(onAddRolePress)
				if !isLast && !isEmpty{
					title = data.roles[indexPath.row].name
					subtitle = nil
					barColor = data.roles[indexPath.row].color
				}
			}
			if isEmpty{
				let cell = UITableViewCell()
				var configuration = cell.defaultContentConfiguration()
				configuration.text = "No \(addCardLabel) Found"
				configuration.textProperties.font = .preferredFont(forTextStyle: .body)
				configuration.textProperties.color = .systemGray
				configuration.textProperties.alignment = .center
				
				cell.contentConfiguration = configuration
				return cell
			} else if isLast {
				let cell = tableView.dequeueReusableCell(withIdentifier: "addCard", for: indexPath) as! AddCardCell
				cell.addCardButton.setTitle("Select \(addCardLabel)", for: .normal)
				cell.addCardButton.addTarget(self, action: selector, for: .touchUpInside)
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell
				
				let gestureRecognizer = CellTapGestureRecognizer( indexPath: indexPath, target: self, action: #selector(onDeletePress))
				cell.card.rightImageView.addGestureRecognizer(gestureRecognizer)
				cell.card.rightImageView.isUserInteractionEnabled = true
				cell.card.title = title
				cell.card.subtitle = subtitle
				cell.card.barView.backgroundColor = UIColor(hex: barColor!)
				
				return cell
			}
		}
    }
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			return nil
		}
		let header = tableView.dequeueReusableCell(withIdentifier: "header") as! SectionHeaderCell
		
		if section == 1 {
			header.sectionTitle.text = "Details"
		} else if section == 2 {
			header.sectionTitle.text = "Branch (Optional)"
		} else if section == 3 {
			header.sectionTitle.text = "Role (Optional)"
		}
		
		return header.contentView
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0{return 0}
		return 42
	}
}


extension AddEmployeeTVC: UIPickerViewDelegate, UIPickerViewDataSource{
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return AppRole.allCases.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return AppRole.allCases[row].rawValue
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if let cell = tableView.cellForRow(at: IndexPath(row: 5, section: 1)) as? SelectFieldCell{
			cell.selectButton.setTitle(AppRole.allCases[row].rawValue, for: .normal)
		}
		
	}
}

extension AddEmployeeTVC{
	
	@objc func onSelectImagePress(){
		print("pressed")
	}
	
	@objc func nameDidChange(_ textField: UITextField) {
		tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
	}

	@objc func onDeletePress(_ recongniser: CellTapGestureRecognizer){
		let indexPath = recongniser.indexPath
		if indexPath.section == 2 {
			let previousShouldShowAddBranch = shouldShowAddBranch
			data.branches.remove(at: indexPath.row)
			if shouldShowAddBranch != previousShouldShowAddBranch{
				tableView.beginUpdates()
				tableView.reloadData()
				tableView.endUpdates()
			} else {
				tableView.deleteRows(at: [indexPath], with: .automatic)
			}
		} else {
			let previousShouldShowAddRole = shouldShowAddRole
			data.roles.remove(at: indexPath.row)
			if shouldShowAddRole != previousShouldShowAddRole{
				tableView.beginUpdates()
				tableView.reloadData()
				tableView.endUpdates()
			} else {
				tableView.deleteRows(at: [indexPath], with: .automatic)
			}
		}
	}
	
	@objc func onAddBranchPress(){
		DispatchQueue.main.async {
			let viewController = UIStoryboard(name: "BranchPicker", bundle: nil).instantiateViewController(withIdentifier: "BranchPickerVC") as! BranchPickerVC
			
			viewController.delegate = self
			viewController.branches =  viewController.branches.filter{mainBranch in
					return !self.data.branches.contains(where: {branch in
						return branch.id == mainBranch.id
					})
				}
			self.present(UINavigationController(rootViewController: viewController), animated: true)
		}
	}
	
	@objc func onAddRolePress(){
		DispatchQueue.main.async {
			let viewController = UIStoryboard(name: "RolePicker", bundle: nil).instantiateViewController(withIdentifier: "RolePickerVC") as! RolePickerVC
			
			viewController.delegate = self
			viewController.roles = viewController.roles.filter{mainRole in
					return !self.data.roles.contains(where: {role in
						return role.id == mainRole.id
					})
				}
			self.present(UINavigationController(rootViewController: viewController), animated: true)
		}
	}
	
}

extension AddEmployeeTVC: BranchPickerDelegate, RolePickerDelegate{
	func onSelectBranch(branch: Branch) {
		tableView.performBatchUpdates({
			data.branches.append(branch)
			if !shouldShowAddBranch {
				tableView.reloadRows(at: [IndexPath(row: data.branches.count - 1, section: 2)], with: .automatic)
			} else if data.branches.count == 1 {
				tableView.insertRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)				
			} else {
				tableView.insertRows(at: [IndexPath(row: data.branches.count - 1, section: 2)], with: .automatic)
			}
		})
	}
	
	func onCancelBranchPicker() {
		print("branch picker cancelled")
	}
	
	func onSelectRole(role: Role) {
		tableView.performBatchUpdates({
			data.roles.append(role)
			if !shouldShowAddRole {
				tableView.reloadRows(at: [IndexPath(row: data.roles.count - 1, section: 3)], with: .automatic)
			} else if data.roles.count == 1 {
				tableView.insertRows(at: [IndexPath(row: 0, section: 3)], with: .automatic)
			} else {
				tableView.insertRows(at: [IndexPath(row: data.roles.count - 1, section: 3)], with: .automatic)
			}
		})
	}
	
	func onCancelRolePicker() {
		print("role picker cancelled")
	}
}

class CellTapGestureRecognizer: UITapGestureRecognizer{
	var indexPath: IndexPath
	
	init(indexPath: IndexPath, target: Any?, action: Selector?) {
		self.indexPath = indexPath

		super.init(target: target, action: action)
	}
}
