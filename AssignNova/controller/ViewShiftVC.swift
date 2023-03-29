//
//  ViewShiftVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit
import LetterAvatarKit
import FirebaseFirestore

enum ActionType{
	case takeShift
	case none
}

class ViewShiftVC: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var leftActionButton: UIButton!
	@IBOutlet weak var rightActionButton: UIButton!
	
	private var reference: DocumentReference?
	var isOpenShifts: Bool{
		if let employees = shift?.eligibleEmployees{
			return employees.count == 0
		}
		return false
	}
	
	private var listener: ListenerRegistration?
	
	var shiftId: String?
	var shift: Shift?
	var leftActionType: ActionType = .none
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.sectionHeaderTopPadding = 0
		tableView.contentInset.bottom = 16
		
		refreshData()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		listener?.remove()
		
		super.viewDidDisappear(animated)
	}
	
	func refreshData(){
		listener?.remove()
		listener = FirestoreHelper.getShift(shiftId: shiftId ?? ""){ shift in
			if let shift = shift{
				self.shift = shift
				self.tableView.reloadData()
				if let employeeId = ActiveEmployee.instance?.employee.id{
					if let noOfShifts = shift.noOfOpenShifts, noOfShifts > 0, let eligibleEmployee = shift.eligibleEmployees, (eligibleEmployee.count == 0) || (eligibleEmployee.contains(employeeId)){
						self.leftActionType = .takeShift
						self.leftActionButton.isHidden = false
						self.leftActionButton.setTitle("Take Shift", for: .normal)
						self.leftActionButton.tintColor = UIColor(named: "AccentColor")
						return
					}
				}
				self.leftActionButton.isHidden = true
				self.rightActionButton.isHidden = true
			}
		}
	}
	
	@IBAction func onEditPress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Shift", bundle: nil).instantiateViewController(withIdentifier: "AddShiftTVC") as! AddShiftTVC
		viewController.shift = shift
		viewController.isEdit = true
		viewController.delegate = self
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
	
	@IBAction func onLeftActionButtonPress(_ sender: UIButton) {
		if let shift = shift{
			print("inside")
			if leftActionType == .takeShift{
				self.startLoading()
				self.reference = FirestoreHelper.takeShift(shift){error in
					if let _ = error {
						self.stopLoading(){
							self.showAlert(title: "Oops", message: "Unknown error occured")
						}
						return
					}
					self.shiftId = self.reference?.documentID
					self.stopLoading()
					self.refreshData()
				}
			}
		}
	}
	
	@IBAction func onRightActionButtonPress(_ sender: UIButton) {
	}
}

extension ViewShiftVC: UITableViewDelegate, UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
		return 4 + (isOpenShifts && ((shift?.eligibleEmployees?.count ?? 0) > 0) ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 || section == 2 {
			return 1
		} else if isOpenShifts {
			if section == 3 { return 1 }
			return shift?.eligibleEmployees?.count ?? 0
		}
		return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0{
			let cell = tableView.dequeueReusableCell(withIdentifier: "details", for: indexPath) as! ShiftDetailsCell
			if let shift = shift{
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "EEEE, MMM d, YYYY"
				cell.dateLabel.text = dateFormatter.string(from: shift.shiftStartDate)
				cell.shiftTime.text = Date.buildTimeRangeString(startDate: shift.shiftStartTime, endDate: shift.shiftEndTime)
				
				if let unpaidBreak = shift.unpaidBreak{
					cell.unpaidBreak.text = "\(unpaidBreak) mins Unpaid Break"
					cell.unpaidBreak.isHidden = false
				} else {
					cell.unpaidBreak.isHidden = true
				}
				
				if let notes = shift.notes, !notes.isEmpty{
					cell.noteHeadingLabel.isHidden = false
					cell.noteLabel.text = notes
				} else {
					cell.noteHeadingLabel.isHidden = true
					cell.noteLabel.isHidden = true
				}
			}
			return cell
		} else{
			let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell
			if indexPath.section == 1{
				let branch = ActiveEmployee.instance?.getBranch(branchId: shift?.branchId ?? "")
				cell.card.title = branch?.name
				cell.card.subtitle = branch?.address
				cell.card.barView.backgroundColor = UIColor(hex: branch?.color ?? "")
				cell.card.profileAvatarContainer.isHidden = true
				cell.card.rightImageContainer.isHidden = false
			} else if indexPath.section == 2{
				let role = ActiveEmployee.instance?.getRole(roleId: shift?.roleId ?? "")				
				cell.card.title = role?.name
				cell.card.subtitle = nil
				cell.card.barView.backgroundColor = UIColor(hex: role?.color ?? "")
				cell.card.profileAvatarContainer.isHidden = true
				cell.card.rightImageContainer.isHidden = false
			} else if indexPath.section == 3 {
				if isOpenShifts{
					cell.card.title = "Open Shift (\(shift?.noOfOpenShifts ?? 0) remaining)"
					cell.card.barView.backgroundColor = ColorPickerVC.colors.first?.color
					cell.card.profileAvatar.image = .makeLetterAvatar(withName: "Open Shift").0
					cell.card.profileAvatarContainer.isHidden = false
					cell.card.rightImageContainer.isHidden = true
				} else {
					let employeeId = shift?.employeeId ?? ""
					let item = ActiveEmployee.instance?.getEmployee(employeeId: employeeId)
					cell.card.title = item?.name
					cell.card.profileAvatarContainer.isHidden = true
					cell.card.barView.backgroundColor = UIColor(hex: item?.color ?? "")
					cell.card.rightImageContainer.isHidden = false
				}
			} else if indexPath.section == 4{
				let employeeId = shift?.eligibleEmployees?[indexPath.row] ?? ""
				let item = ActiveEmployee.instance?.getEmployee(employeeId: employeeId)
				cell.card.title = item?.name
				cell.card.profileAvatarContainer.isHidden = true
				cell.card.barView.backgroundColor = UIColor(hex: item?.color ?? "")
				cell.card.rightImageContainer.isHidden = false
			}
			
			return cell
		}
    }
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			return nil
		}
		let header = tableView.dequeueReusableCell(withIdentifier: "header") as! SectionHeaderCell
		
		if section == 1 {
			header.sectionTitle.text = "Branch"
		} else if section == 2 {
			header.sectionTitle.text = "Role"
		} else if section == 3 {
			header.sectionTitle.text = "Employees"
		} else if section == 4 {
			header.sectionTitle.text = "Eligible Employees"
		}
		
		return header.contentView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0{return 0}
		return 42
	}
}

extension ViewShiftVC: AddShiftDelegate{
	func dismissScreen() {
		navigationController?.popViewController(animated: true)
	}
}
