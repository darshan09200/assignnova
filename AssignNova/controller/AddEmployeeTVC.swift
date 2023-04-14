//
//  AddEmployeeTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit
import LetterAvatarKit
import FirebaseFirestore
import FirebaseStorage

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
		(isEdit ? ActionsHelper.canEdit(employee: employee) : true) && data.branches.count < ActiveEmployee.instance!.branches.count
	}

	var isRoleEmpty: Bool{
		ActiveEmployee.instance!.roles.count == 0
	}

	var shouldShowAddRole: Bool{
		(isEdit ? ActionsHelper.canEdit(employee: employee) : true)  && data.roles.count < ActiveEmployee.instance!.roles.count
	}

	var isEdit: Bool = false
	var employee: Employee?
	var currentEmployee: Employee?
	
	var maxHoursInput = "40"
	
	var profilePath: String?
	
	lazy var imagePickerController = ImagePicker(presentationController: self, delegate: self)

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.sectionHeaderTopPadding = 0
		tableView.contentInset.bottom = 16

		if isEdit, let employee = employee{
			navigationItem.title = "Edit Employee"
			
			self.currentEmployee = employee
		} else {
			self.currentEmployee = Employee(firstName: "", lastName: "", appRole: .employee, email: "", color: "")
		}
	}

	@IBAction func onCancelPress(_ sender: Any) {
		dismiss(animated: true)
	}

	@IBAction func onSavePress(_ sender: Any) {
		guard let firstName = currentEmployee?.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
				!firstName.isEmpty
		else {
			showAlert(title: "Oops", message: "First Name is empty")
			return
		}

		guard let lastName = currentEmployee?.lastName.trimmingCharacters(in: .whitespacesAndNewlines),
			  !lastName.isEmpty
		else {
			showAlert(title: "Oops", message: "Last Name is empty")
			return
		}

		guard let email = currentEmployee?.email.trimmingCharacters(in: .whitespacesAndNewlines),
			  !email.isEmpty
		else {
			showAlert(title: "Oops", message: "Email is empty")
			return
		}

		var phoneNumber = currentEmployee?.phoneNumber?.isEmpty ?? true ? nil : currentEmployee?.phoneNumber
		
		let employeeId = currentEmployee?.employeeId?.isEmpty ?? true ? nil : currentEmployee?.employeeId

		let role = currentEmployee?.appRole ?? .employee

		let hours = maxHoursInput.trimmingCharacters(in: .whitespacesAndNewlines)
		if hours.isEmpty{
			showAlert(title: "Oops", message: "Max Hours is empty")
			return
		}

		guard let maxHours = Double(hours) else {
			showAlert(title: "Oops", message: "Max Hours in invalid")
			return
		}

		if !ValidationHelper.isValidEmail(email){
			showAlert(title: "Oops", message: "Email is invalid")
			return
		} else if let nestedPhoneNumber = phoneNumber, !nestedPhoneNumber.isEmpty{
			if let phoneNumberDetails = ValidationHelper.phoneNumberDetails(nestedPhoneNumber){
				if let region = phoneNumberDetails.regionID, region != "US" && region != "CA" {
					if let regionName = ValidationHelper.getRegionName(phoneNumberDetails){
						showAlert(title: "Oops", message: "\(regionName) is not yet supported")
					} else {
						showAlert(title: "Oops", message: "Country not supported")
					}
					return
				} else {
					let formattedPhoneNumber = ValidationHelper.formatPhoneNumber(phoneNumberDetails)
					phoneNumber = formattedPhoneNumber
				}
			} else {
				showAlert(title: "Oops", message: "Phone Number is invalid")
				return
			}
		}

		self.startLoading()
		FirestoreHelper.doesEmployeeExist(email: email, phoneNumber: phoneNumber, employeeId: employee?.id){ existingEmployee in
			if let existingEmployee = existingEmployee {
				self.stopLoading(){
					var message = " already linked with another employee: \(existingEmployee.name)"
					if existingEmployee.phoneNumber == phoneNumber && !(existingEmployee.phoneNumber?.isEmpty ?? false){
						message = "Phone Number"+message
					} else {
						message = "Email"+message
					}
					self.showAlert(title: "Oops", message: message )
				}
			} else {
				let (_, backgroundColor) = UIImage.makeLetterAvatar(withName: self.currentEmployee?.name ?? "", backgroundColor: UIColor(hex: self.employee?.color ?? ""))
				var employee = Employee(
					id: self.employee?.id,
					userId: self.employee?.userId,
					employeeId: employeeId,
					firstName: firstName,
					lastName: lastName,
					appRole: role,
					maxHours: maxHours,
					isProfilePrivate: self.employee?.isProfilePrivate ?? false,
					profileUrl: self.currentEmployee?.profileUrl,
					email: email,
					phoneNumber: phoneNumber,
					invited: self.employee?.invited ?? true,
					branches: self.data.branches.compactMap{$0.id},
					roles: self.data.roles.compactMap{$0.id},
					color: backgroundColor.toHex ?? "",
					fcmToken: self.employee?.fcmToken,
					createdAt: self.employee?.createdAt)
				employee.customerId = self.employee?.customerId
				var reference: DocumentReference?
				reference = FirestoreHelper.saveEmployee(employee){error in
					if let _ = error {
						self.stopLoading(){
							self.showAlert(title: "Oops", message: "Unknown error occured")
						}
						return
					}
					if let profilePath = self.profilePath,
					   let employeeId = reference?.documentID ?? employee.id{
					   let storageRef = Storage.storage().reference().child("profileImages").child("\(employeeId).jpg")
						
						storageRef.putFile(from: URL(fileURLWithPath: profilePath, isDirectory: false)) { (metadata, error) in
							if error == nil {
								employee.id = employeeId
								employee.profileUrl = storageRef.fullPath
								FirestoreHelper.saveEmployee(employee){error in
									if let _ = error {
										print(error?.localizedDescription)
										self.stopLoading(){
											self.showAlert(title: "Oops", message: "Unknown error occured")
										}
										return
									}
									self.stopLoading(){
										self.dismiss(animated: true)
									}
								}
							} else {
								print(error?.localizedDescription)
								self.stopLoading(){
									self.dismiss(animated: true)
								}
							}
						}
					} else {
						self.stopLoading(){
							self.dismiss(animated: true)
						}
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
			cell.removeImageButton.isHidden = true
			if let profilePath = profilePath,
				let imageData = try? Data(contentsOf: URL(fileURLWithPath: profilePath, isDirectory: false)) {
				cell.profileImage.image = UIImage(data: imageData)
				cell.removeImageButton.isHidden = false
			} else if let profileUrl = currentEmployee?.profileUrl{
				let reference = Storage.storage().reference().child(profileUrl)
				cell.profileImage.sd_imageTransition = .fade
				cell.profileImage.sd_setImage(with: reference, maxImageSize: 1 * 1024 * 1024, placeholderImage: nil, options: [.refreshCached])
				cell.removeImageButton.isHidden = false
			} else if let employee = currentEmployee, !employee.name.isEmpty {
				let (image, _) = UIImage.makeLetterAvatar(withName: employee.name, backgroundColor: UIColor(hex: employee.color))
				cell.profileImage.image = image
			} else {
				let (image, _) = UIImage.makeLetterAvatar(withName: "John Doe")
				cell.profileImage.image = image
			}
			cell.addImageButton?.isHidden = !ActionsHelper.isSelf(employee: employee)
			cell.removeImageButton?.isHidden = !ActionsHelper.isSelf(employee: employee)
			cell.addImageButton?.addTarget(self, action: #selector(onSelectImagePress), for: .touchUpInside)
			cell.removeImageButton?.addTarget(self, action: #selector(onRemoveImagePress), for: .touchUpInside)

			return cell
		} else if indexPath.section == 1{
			
			
			if indexPath.row == 5{
				let cell = tableView.dequeueReusableCell(withIdentifier: "selectForm", for: indexPath) as! SelectFieldCell
				cell.selectButton.isEnabled = isEdit ? ActionsHelper.canEdit(employee: employee) : true
				cell.picker?.delegate = self
				cell.picker?.dataSource = self
				cell.label.text = "Role"
				cell.selectButton.setTitle((currentEmployee?.appRole ?? .employee).rawValue, for: .normal)
				cell.picker?.selectRow((currentEmployee?.appRole ?? .employee).index ?? 0, inComponent: 0, animated: true)
				return cell
			}
			
			
			
			var label: String = ""
			var placeholder: String = ""
			var defaultValue: String? = nil
            var contentType: UITextContentType?
            var keyType: UIKeyboardType?
            var capitalLetter: UITextAutocapitalizationType?

			let cell = tableView.dequeueReusableCell(withIdentifier: "inputForm", for: indexPath) as! InputFieldCell

			switch indexPath.row {
				case 0:
					label = "First Name"
					placeholder = "John"
                    contentType = .name
                    keyType = .default
                    capitalLetter = .words
					defaultValue = currentEmployee?.firstName
					cell.inputField.textFieldComponent.addTarget(self, action: #selector(firstNameDidChange(_:)), for: .editingChanged)
				case 1:
					label = "Last Name"
					placeholder = "Doe"
                    contentType = .name
                    keyType = .default
                    capitalLetter = .words
					defaultValue = currentEmployee?.lastName
					cell.inputField.textFieldComponent.addTarget(self, action: #selector(lastNameDidChange(_:)), for: .editingChanged)

				case 2:
					label = "Email"
					placeholder = "abc@xyz.com"
                    contentType = .emailAddress
                    keyType = .emailAddress
					defaultValue = currentEmployee?.email
					cell.inputField.textFieldComponent.addTarget(self, action: #selector(emailDidChange(_:)), for: .editingChanged)

				case 3:
					label = "Phone Number (Optional)"
					placeholder = "+12345678901"
                    contentType = .telephoneNumber
                    keyType = .phonePad
					defaultValue = currentEmployee?.phoneNumber
					cell.inputField.textFieldComponent.addTarget(self, action: #selector(phoneNumberDidChange(_:)), for: .editingChanged)

				case 4:
					label = "Employee Id (Optional)"
					defaultValue = currentEmployee?.employeeId
					cell.inputField.textFieldComponent.addTarget(self, action: #selector(employeeIdDidChange(_:)), for: .editingChanged)

				case 6:
					label = "Max Hours/Week"
                    keyType = .decimalPad
					defaultValue = String(format: "%.2f", currentEmployee?.maxHours ?? 40.0)
					cell.inputField.textFieldComponent.addTarget(self, action: #selector(hoursDidChange(_:)), for: .editingChanged)

				default: break
			}
			
			cell.inputField.label = label
			cell.inputField.placeholder = placeholder
			if indexPath.row == 4 || indexPath.row == 6 {
				cell.inputField.textFieldComponent.isEnabled = isEdit ? ActionsHelper.canEdit(employee: employee) : true
			}
			if isEdit && indexPath.row == 2 {
				cell.inputField.textFieldComponent.isEnabled = false
			}
			cell.inputField.textFieldComponent.text = defaultValue
            cell.inputField.textFieldComponent.textContentType = contentType
            cell.inputField.textFieldComponent.keyboardType = keyType ?? .default
            cell.inputField.textFieldComponent.autocapitalizationType = capitalLetter ?? .none
            cell.inputField.textFieldComponent.autocapitalizationType = capitalLetter ?? .none
			
			return cell
		} else {
			let isLast: Bool
			let isEmpty: Bool
			let addCardLabel: String
			let selector: Selector
			var title: String?
			var subtitle: String?
			var barColor: String?
			print("\(indexPath.section) inside")
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
				cell.card.rightImageContainer.isHidden = !ActionsHelper.canEdit(employee: employee)
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
			let appRole = AppRole.allCases[row]
			cell.selectButton.setTitle(appRole.rawValue, for: .normal)
			currentEmployee?.appRole = appRole
		}

	}
}

extension AddEmployeeTVC{

	@objc func onSelectImagePress(){
		imagePickerController.present()
	}
	
	@objc func onRemoveImagePress(){
		print("called")
		profilePath = nil
		currentEmployee?.profileUrl = nil
		tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
	}

	@objc func firstNameDidChange(_ textField: UITextField) {
		if profilePath == nil && currentEmployee?.profileUrl == nil {
			tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
		}
		
		currentEmployee?.firstName = textField.text ?? ""

	}
	
	@objc func lastNameDidChange(_ textField: UITextField) {
		if profilePath == nil && currentEmployee?.profileUrl == nil {
			tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
		}
		currentEmployee?.lastName = textField.text ?? ""

	}

	@objc func emailDidChange(_ textField: UITextField) {
		currentEmployee?.email = textField.text ?? ""
	}

	@objc func phoneNumberDidChange(_ textField: UITextField) {
		currentEmployee?.phoneNumber = textField.text ?? ""
	}

	@objc func employeeIdDidChange(_ textField: UITextField) {
		currentEmployee?.employeeId = textField.text ?? ""
	}
	
	@objc func hoursDidChange(_ textField: UITextField) {
		maxHoursInput = textField.text ?? ""
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

extension AddEmployeeTVC: ImagePickerDelegate{
	func didSelect(image: UIImage?) {
		if let image = image{
			let path = FileHandling.saveToDirectory(image)
			if let path = path{
				self.profilePath = path
				print(profilePath)
				tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
				return
			}
			
		}
		print("no image")
	}
}
