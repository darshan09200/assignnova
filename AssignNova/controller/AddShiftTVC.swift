//
//  AddShiftTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit
import LetterAvatarKit
import FirebaseFirestore

protocol AddShiftDelegate{
	func dismissScreen()
}

struct AddShiftModel{
	var branch: Branch?
	var role: Role?
	var employees  = [Employee]()
	var eligibileEmployees = [Employee]()
	var selectedDate: Date = .now
	var startTime: Date = .now.getNearest15()
	var endTime: Date = .now.getNearest15().add(minute: 15)
	var color: Color = ColorPickerVC.colors.first!
}

class AddShiftTVC: UITableViewController {
	
	var data = AddShiftModel()
	
	var isBranchEmpty: Bool{
		ActiveEmployee.instance!.branches.count == 0
	}
	
	var isBranchSelected: Bool{
		data.branch != nil
	}
	
	var isRoleEmpty: Bool{
		ActiveEmployee.instance!.roles.count == 0
	}
	
	var isRoleSelecetd: Bool{
		data.role != nil
	}
	
	var isOpenShifts: Bool{
		data.employees.count == 0
	}
	
	var didOpenFromEligibileEmployees = false
	
	var isEdit: Bool = false
	var shift: Shift?
	var delegate: AddShiftDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.sectionHeaderTopPadding = 0
		tableView.contentInset.bottom = 16
		
		if isEdit, let shift = shift{
			
			navigationItem.title = "Edit Shift"
			
			data.selectedDate = shift.shiftStartDate.timeIntervalSinceNow.sign == .minus ? .now : shift.shiftStartDate
			
			data.startTime = shift.shiftStartTime
			data.endTime = shift.shiftEndTime
			
			data.color = ColorPickerVC.colors.first{shift.color == $0.color.toHex} ?? data.color
			if let branch = ActiveEmployee.instance?.branches.first(where: {$0.id == shift.branchId}){
				data.branch = branch
			}
			
			if let role = ActiveEmployee.instance?.roles.first(where: {$0.id == shift.roleId}){
				data.role = role
			}
			
			if let employee = ActiveEmployee.instance?.employees.first(where: {$0.id == shift.employeeId}){
				data.employees = [employee]
			}
			
			if let eligibileEmployees = ActiveEmployee.instance?.employees.filter({employee in
				return shift.eligibleEmployees?.contains{employee.id == $0} ?? false
			}){
				data.eligibileEmployees = eligibileEmployees
			}

		}
	}
	
	@IBAction func onCancelPress(_ sender: Any) {
		dismiss(animated: true)
	}
	
	@IBAction func onSavePress(_ sender: Any) {
		let shiftDate = data.selectedDate.startOfDay
		
		let startTime = data.startTime
		let endTime = data.endTime
		
		let color = data.color
		
		let unpaidBreak: Int?
		if let unpaidBreakCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? InputFieldCell{
			if let unpaidBreakInput  = unpaidBreakCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines), !unpaidBreakInput.isEmpty{
				guard let convertedUnpaidBreak = Int(unpaidBreakInput) else {
					showAlert(title: "Oops", message: "Unpaid break in invalid")
					return
				}
				unpaidBreak = convertedUnpaidBreak
			}else {
				unpaidBreak = nil
			}
		} else {
			unpaidBreak = nil
		}
		
		let notes: String?
		if let notesCell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? InputFieldCell{
			notes  = notesCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines)
		}else {
			notes = nil
		}
		
		guard let branch = data.branch else {
			showAlert(title: "Oops", message: "Select a branch for the shift")
			return
		}
		guard let role = data.role else {
			showAlert(title: "Oops", message: "Select a role for the shift")
			return
		}
		
		let noOfShifts: Int?
		if isOpenShifts{
			guard let noOfShiftsCell = tableView.cellForRow(at: IndexPath(row: 2, section: 3)) as? InputFieldCell,
				  let noOfShiftsInput = noOfShiftsCell.inputField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines),
				  !noOfShiftsInput.isEmpty
			else {
				showAlert(title: "Oops", message: "No of Shifts is empty")
				return
			}
			
			guard let convertedNoOfShifts = Int(noOfShiftsInput) else {
				showAlert(title: "Oops", message: "No of Shifts in invalid")
				return
			}
			noOfShifts = convertedNoOfShifts
		} else{
			noOfShifts = nil
		}
		
		
		self.startLoading()
		if isOpenShifts{
			let shift = Shift(id: shift?.id, shiftStartDate: shiftDate, shiftStartTime: startTime, shiftEndTime: endTime, unpaidBreak: unpaidBreak, branchId: branch.id!, roleId: role.id!, color: color.color.toHex ?? "", notes: notes, eligibleEmployees: data.eligibileEmployees.compactMap{$0.id}, noOfOpenShifts: noOfShifts, updatedAt: shift?.updatedAt)
			
			FirestoreHelper.saveShift(shift){error in
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
		} else {
			let shifts = data.employees.compactMap{
				Shift(shiftStartDate: shiftDate, shiftStartTime: startTime, shiftEndTime: endTime, unpaidBreak: unpaidBreak, branchId: branch.id!, roleId: role.id!, color: color.color.toHex ?? "", notes: notes, employeeId: $0.id)
			}
			
			FirestoreHelper.saveShifts(shifts){error in
				if let _ = error {
					self.stopLoading(){
						self.showAlert(title: "Oops", message: "Unknown error occured")
					}
					return
				}
				self.stopLoading(){
					self.dismiss(animated: true)
					if self.isEdit, let shiftId = self.shift?.id{
						FirestoreHelper.deleteShift(shiftId){err in}
						self.delegate?.dismissScreen()
					}
				}
			}
		}
		
	}
}

extension AddShiftTVC{

    override func numberOfSections(in tableView: UITableView) -> Int {
		return 4 + (isOpenShifts ? 1 : 0)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 5}
		if section == 1 {
			return 1 + (isBranchSelected ? 1 : 0)
		}
		if section == 2 {
			return 1 + (isRoleSelecetd ? 1 : 0)
		} else if isOpenShifts {
			print("open shift")
			if section == 3 {return 3}
			return data.eligibileEmployees.count + 1
		}
		return data.employees.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0{
			var label: String = ""
			var placeholder: String = ""
			var defaultValue: String? = nil
			var tintColor: UIColor? = nil
			var isMultiline = false
			switch indexPath.row {
				case 0:
					label = "Date"
					placeholder = data.selectedDate.format(to: "EEE, MMM dd, yyyy")
				case 1:
					label = "Time"
					placeholder = Date.buildTimeRangeString(startDate: data.startTime, endDate: data.endTime)
				case 2:
					label = "Color"
					defaultValue = data.color.name
					tintColor = data.color.color
				case 3:
					label = "Unpaid Break(minutes)"
					placeholder = "30"
				case 4:
					label = "Notes"
					isMultiline = true
				default: break
			}
			if indexPath.row == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "selectForm", for: indexPath) as! SelectFieldCell
				let picker = UIDatePicker()
				picker.minimumDate = .now
				picker.datePickerMode = .date
				picker.preferredDatePickerStyle = .wheels
				picker.addTarget(self, action: #selector(onShiftDateChanged), for: .valueChanged)
				cell.datePicker = picker
				cell.label.text = label
				cell.selectButton.setTitle(placeholder, for: .normal)
				return cell
			} else if indexPath.row == 1{
				let cell = tableView.dequeueReusableCell(withIdentifier: "selectForm", for: indexPath) as! SelectFieldCell
				
				cell.delegate = self
				
				cell.picker?.delegate = self
				cell.picker?.dataSource = self
				
				cell.label.text = label
				cell.selectButton.setTitle(placeholder, for: .normal)
				
				return cell
			} else if indexPath.row == 2{
				let cell = tableView.dequeueReusableCell(withIdentifier: "color", for: indexPath) as! ColorPickerCell
				cell.colorImage.tintColor = tintColor
				cell.colorLabel.text = defaultValue
				cell.colorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectColorPress)))
				cell.colorView.isUserInteractionEnabled = true
				return cell
			}
			let cell = tableView.dequeueReusableCell(withIdentifier: "inputForm", for: indexPath) as! InputFieldCell
			cell.inputField.label = label
			cell.inputField.placeholder = placeholder
			cell.inputField.textFieldComponent.text = defaultValue
			if isMultiline{
				
			}
			cell.inputField.leftIconColor = tintColor
			
			return cell
		} else{
			if isRoleEmpty || isBranchEmpty{
				let cell = UITableViewCell()
				var configuration = cell.defaultContentConfiguration()
				configuration.text = "No \(indexPath.section == 1 ? "Branch" : "Role") Found"
				configuration.textProperties.font = .preferredFont(forTextStyle: .body)
				configuration.textProperties.color = .systemGray
				configuration.textProperties.alignment = .center
				
				cell.contentConfiguration = configuration
				return cell
			} else if (indexPath.section == 1 && indexPath.row == (isBranchSelected ? 1 : 0)) ||
						(indexPath.section == 2 && indexPath.row == (isRoleSelecetd ? 1 : 0)) ||
						(indexPath.section == 3 && indexPath.row == max(1, data.employees.count) ||
						 (indexPath.section == 4 && indexPath.row == data.eligibileEmployees.count)){
				let cell = tableView.dequeueReusableCell(withIdentifier: "addCard", for: indexPath) as! AddCardCell
				cell.addCardButton.setTitle("Select \(indexPath.section == 1 ? "Branch" : indexPath.section == 2 ? "Role" : indexPath.section == 3 ? "Employees" : "Eligible Employees" )", for: .normal)
				cell.addCardButton.addTarget(
					self,
					action:
						indexPath.section == 1 ? #selector(onAddBranchPress) :
						indexPath.section == 2 ? #selector(onAddRolePress) :
						indexPath.section == 3 ? #selector(onAddEmployeePress):
						#selector(onAddEligibleEmployeePress), for: .touchUpInside)
				return cell
			} else if indexPath.section == 3 && indexPath.row == 2 && isOpenShifts{
				let cell = tableView.dequeueReusableCell(withIdentifier: "inputForm", for: indexPath) as! InputFieldCell
				cell.inputField.label = "Number of Open Shifts"
				cell.inputField.placeholder = "1"
				cell.inputField.textFieldComponent.text = "1"
				
				return cell
			} else {
				print(indexPath)
				let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell
				
				cell.card.rightIconClosure = {
					self.onDeletePress(indexPath)
				}
				if indexPath.section == 1 {
					let item = data.branch
					cell.card.title = item?.name
					cell.card.subtitle = item?.address
					cell.card.barView.backgroundColor = UIColor(hex: item?.color ?? "")
				} else if indexPath.section == 2 {
					let item = data.role
					cell.card.title = item?.name
					cell.card.subtitle = nil
					cell.card.barView.backgroundColor = UIColor(hex: item?.color ?? "")
				} else if indexPath.section == 3 {
					if isOpenShifts{
						cell.card.title = "Open Shift"
						cell.card.barView.backgroundColor = ColorPickerVC.colors.first?.color
						cell.card.profileAvatar.image = .makeLetterAvatar(withName: "Open Shift").0
						cell.card.profileAvatarContainer.isHidden = false
						cell.card.rightImageContainer.isHidden = true
					} else {
						let item = data.employees[indexPath.row]
						cell.card.title = "\(item.firstName) \(item.lastName)"
						cell.card.profileAvatarContainer.isHidden = true
						cell.card.barView.backgroundColor = UIColor(hex: item.color)
						cell.card.rightImageContainer.isHidden = false
					}
				} else if indexPath.section == 4{
					let item = data.eligibileEmployees[indexPath.row]
					cell.card.title = "\(item.firstName) \(item.lastName)"
					cell.card.profileAvatarContainer.isHidden = true
					cell.card.barView.backgroundColor = UIColor(hex: item.color)
					cell.card.rightImageContainer.isHidden = false
				}
				
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
			header.sectionTitle.text = "Branch"
		} else if section == 2 {
			header.sectionTitle.text = "Role"
		} else if section == 3 {
			header.sectionTitle.text = "Employee (Optional)"
		} else if section == 4 {
			header.sectionTitle.text = "Eligible Employees"
		}
		
		return header.contentView
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0{return 0}
		return 42
	}
}


extension AddShiftTVC{
	
	@objc func onSelectImagePress(){
		print("pressed")
	}
	
	@objc func nameDidChange(_ textField: UITextField) {
		tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
	}

	@objc func onDeletePress(_ indexPath: IndexPath){
		if indexPath.section == 1 {
			data.branch = nil
			tableView.deleteRows(at: [indexPath], with: .automatic)
		} else if indexPath.section == 2{
			data.role = nil
			tableView.deleteRows(at: [indexPath], with: .automatic)
		} else {
			let wasOpenShifts = isOpenShifts
			data.employees.remove(at: indexPath.row)
			tableView.performBatchUpdates({
				if wasOpenShifts && !isOpenShifts{
					tableView.deleteSections(IndexSet(integer: 4), with: .none)
				} else if !wasOpenShifts && isOpenShifts{
					tableView.insertSections(IndexSet(integer: 4), with: .none)
				}
				tableView.reloadSections(IndexSet(integer: 3), with: .none)
			})
		}
	}
	
	@objc func onAddBranchPress(){
		DispatchQueue.main.async {
			let viewController = UIStoryboard(name: "BranchPicker", bundle: nil).instantiateViewController(withIdentifier: "BranchPickerVC") as! BranchPickerVC
			
			viewController.delegate = self
			viewController.selectedBranch = self.data.branch
			self.present(UINavigationController(rootViewController: viewController), animated: true)
		}
	}
	
	@objc func onAddRolePress(){
		DispatchQueue.main.async {
			let viewController = UIStoryboard(name: "RolePicker", bundle: nil).instantiateViewController(withIdentifier: "RolePickerVC") as! RolePickerVC
			
			viewController.delegate = self
			viewController.selectedRole = self.data.role
			self.present(UINavigationController(rootViewController: viewController), animated: true)
		}
	}
	
	@objc func onAddEmployeePress(){
		DispatchQueue.main.async {
			self.present(EmployeePickerVC.getController(delegate: self, selectedEmployees: self.didOpenFromEligibileEmployees ? self.data.eligibileEmployees : self.data.employees), animated: true)
		}
	}
	
	@objc func onAddEligibleEmployeePress(){
		didOpenFromEligibileEmployees = true
		onAddEmployeePress()
	}
	
	@objc func onSelectColorPress() {
		self.present(ColorPickerVC.getController(delegate: self, selectedColor: data.color.color),
					 animated:true, completion: nil)
	}

}

extension AddShiftTVC:ColorPickerDelegate{
	func onSelectColor(color: Color) {
		data.color = color
		tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
	}
	
	func onCancelColorPicker() {
		print("cancelled color picker")
	}
	
	
}

extension AddShiftTVC: BranchPickerDelegate, RolePickerDelegate, EmployeePickerDelegate{
	func onSelectBranch(branch: Branch) {
		let previousIsBranchSelected = isBranchSelected
		data.branch = branch
		if previousIsBranchSelected != isBranchSelected {
			tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
		} else {
			tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
		}
	}
	
	func onCancelBranchPicker() {
		print("branch picker cancelled")
	}
	
	func onSelectRole(role: Role) {
		let previousIsRoleSelected = isRoleSelecetd
		data.role = role
		if previousIsRoleSelected != isRoleSelecetd {
			tableView.insertRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
		} else {
			tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
		}
	}
	
	func onCancelRolePicker() {
		print("role picker cancelled")
	}
	
	func onSelectEmployees(employees: [Employee]) {
		let wasOpenShifts = isOpenShifts
		if didOpenFromEligibileEmployees {
			data.eligibileEmployees = employees
			tableView.reloadSections(IndexSet(integer: 4), with: .none)
		} else {
			data.employees = employees
			tableView.performBatchUpdates({
				tableView.reloadSections(IndexSet(integer: 3), with: .none)
				if wasOpenShifts && !isOpenShifts{
					tableView.deleteSections(IndexSet(integer: 4), with: .none)
				} else if !wasOpenShifts && isOpenShifts {
					tableView.insertSections(IndexSet(integer: 4), with: .none)
				}
			})
		}
		didOpenFromEligibileEmployees = false
	}
	
	func onCancelEmployeePicker() {
		print("cancelled employee picker")
	}
}

extension AddShiftTVC: UIPickerViewDelegate, UIPickerViewDataSource{
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return TimeRangePicker.numberOfComponents(in: pickerView)
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return TimeRangePicker.pickerView(pickerView, numberOfRowsInComponent: component)
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return TimeRangePicker.pickerView(pickerView, titleForRow: row, forComponent: component)
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if let (startTime, endTime) = TimeRangePicker.pickerView(pickerView, didSelectRow: row, inComponent: component){
			
			data.startTime = startTime
			data.endTime = endTime
			
			if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SelectFieldCell{
				cell.selectButton.setTitle(Date.buildTimeRangeString(startDate: data.startTime, endDate: data.endTime), for: .normal)
			}
		}
	}
	
}

extension AddShiftTVC: SelectFieldDelegate{
	func onDonePress(cell: SelectFieldCell) {}
	
	func onOpen(cell: SelectFieldCell){
		let startTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: data.startTime)
		let endTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: data.endTime)
		
		let startTimeIndex = TimeRangePicker.startTimes.firstIndex(where: {
			let components = Calendar.current.dateComponents([.hour, .year, .minute], from: $0)
			return components.minute == startTimeComponents.minute && components.hour == startTimeComponents.hour
		}) ?? 0
		
		let endTimeIndex = TimeRangePicker.endTimes.firstIndex(where:{
			let components = Calendar.current.dateComponents([.hour, .year, .minute], from: $0)
			return components.minute == endTimeComponents.minute && components.hour == endTimeComponents.hour
		}) ?? 0
		
		cell.picker?.selectRow(startTimeIndex, inComponent: 0, animated: true)
		cell.picker?.selectRow(endTimeIndex, inComponent: 1, animated: true)
	}
	
	@objc func onShiftDateChanged(_ datePicker: UIDatePicker){
		data.selectedDate = datePicker.date
		if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SelectFieldCell{
			cell.selectButton.setTitle(data.selectedDate.format(to: "EEE, MMM dd, yyyy"), for: .normal)
		}
	}
}
