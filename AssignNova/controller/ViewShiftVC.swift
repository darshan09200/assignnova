//
//  ViewShiftVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit
import LetterAvatarKit
import FirebaseFirestore
import CoreLocation

enum ActionType: String{
	case takeShift
	case requested
	case approve
	case deny
	case clockIn
	case startBreak
	case endBreak
	case clockOut
	case declined
	case completed
	case none
	case expired
	case offerShift
	case offerApprove
	case offerDeny
	case offerApproved
	case offerDeclined
}

class ViewShiftVC: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var leftActionButton: UIButton!
	@IBOutlet weak var rightActionButton: UIButton!
	var okAction: UIAlertAction?
	
	private var reference: DocumentReference?
	var isOpenShifts: Bool{
		return shift?.employeeId == nil
	}
	
	private var listener: ListenerRegistration?
	
	var shiftId: String?
	var shift: Shift?
	var leftActionType: ActionType = .none
	var rightActionType: ActionType = .none
	
	var locManager = CLLocationManager()
	var currentLocation: CLLocation?
	
	var timer: Timer?

	@IBOutlet weak var editItem: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.sectionHeaderTopPadding = 0
		tableView.contentInset.bottom = 16
		print(shiftId)
		refreshData()
				
		locManager.delegate = self
		locManager.desiredAccuracy = kCLLocationAccuracyBest
			
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		listener?.remove()
		endTimer()
		super.viewDidDisappear(animated)
	}
	
	func refreshData(){
		listener?.remove()
		listener = FirestoreHelper.getShift(shiftId: shiftId ?? ""){ shift in
			if let shift = shift{
				self.shift = shift
				
				self.leftActionButton.isHidden = true
				self.rightActionButton.isHidden = true
				
				if ActionsHelper.canEdit(shift: shift){
					self.editItem.isHidden = false
				} else {
					self.editItem.isHidden = true
				}
				
				let action = ActionsHelper.getAction(for: shift)
				
				print(action.rawValue)
				
				self.leftActionType = .none
				self.rightActionType = .none
				
				self.leftActionButton.isUserInteractionEnabled = true
				self.rightActionButton.isUserInteractionEnabled = true
				
				if action == .takeShift{
					self.leftActionType = .takeShift
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Take Shift", for: .normal)
					self.leftActionButton.tintColor = UIColor(named: "AccentColor")
				} else if action == .approve || action == .offerApprove{
					self.leftActionType = action == .offerApprove ? .offerDeny : .deny
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Deny", for: .normal)
					self.leftActionButton.tintColor = .systemRed
					
					self.rightActionType = action == .offerApprove ? .offerApprove : .approve
					self.rightActionButton.isHidden = false
					self.rightActionButton.setTitle("Approve", for: .normal)
					self.rightActionButton.tintColor = UIColor(named: "AccentColor")
				} else if action == .declined || action == .offerDeclined{
					self.leftActionType = .none
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Declined", for: .normal)
					self.leftActionButton.tintColor = .systemRed
					self.leftActionButton.isUserInteractionEnabled = false
				} else if action == .offerApproved {
					self.leftActionType = .none
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Offered", for: .normal)
					self.leftActionButton.tintColor = .systemYellow
					self.leftActionButton.isUserInteractionEnabled = false
				} else if action == .offerShift{
					self.leftActionType = .offerShift
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Offer Shift", for: .normal)
					self.leftActionButton.tintColor = .systemYellow
				} else if action == .clockIn{
					if self.currentLocation == nil{
						self.locManager.requestWhenInUseAuthorization()
					}
					
					self.rightActionType = .clockIn
					self.rightActionButton.isHidden = false
					self.rightActionButton.setTitle("Clock In", for: .normal)
					self.rightActionButton.tintColor = UIColor(named: "AccentColor")
				} else if action == .clockOut{
					self.startTimer()
					if ActionsHelper.canTakeBreak(shift: shift) {
						self.leftActionType = .startBreak
						self.leftActionButton.isHidden = false
						self.leftActionButton.setTitle("Start Break", for: .normal)
						self.leftActionButton.tintColor = .systemGreen
						if let attendance = shift.attendance, let allowedBreakTime = shift.unpaidBreak, allowedBreakTime > attendance.totalBreakTime {
							self.leftActionButton.isEnabled = true
						} else {
							self.leftActionButton.isEnabled = false
						}
					}
					self.rightActionType = .clockOut
					self.rightActionButton.isHidden = false
					self.rightActionButton.setTitle("Clock Out", for: .normal)
					self.rightActionButton.tintColor = UIColor(named: "AccentColor")
				} else if action == .endBreak{
					self.startTimer()
					self.leftActionType = .endBreak
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("End Break", for: .normal)
					self.leftActionButton.tintColor =  UIColor(named: "AccentColor")
				} else if action == .completed{
					self.leftActionType = .none
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Completed", for: .normal)
					self.leftActionButton.tintColor = UIColor(named: "AccentColor")
					self.leftActionButton.isUserInteractionEnabled = false
				} else if action == .expired {
					self.leftActionType = .none
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Expired", for: .normal)
					self.leftActionButton.tintColor = .systemRed
					self.leftActionButton.isUserInteractionEnabled = false
				} else if action == .requested  {
					self.leftActionType = .none
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Waiting for Approval", for: .normal)
					self.leftActionButton.tintColor = .systemYellow
					self.leftActionButton.isUserInteractionEnabled = false
				}
				
				self.stopLoading(){
					self.tableView.reloadData()
				}

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
		if leftActionType == .takeShift{
			if let shift = shift, ActionsHelper.canTake(shift: shift){
				self.startLoading()
				CloudFunctionsHelper.getEligibleEmployees(branchId: shift.branchId, roleId: shift.roleId, shiftDate: shift.shiftStartDate, startTime: shift.shiftStartTime, endTime: shift.shiftEndTime, skipAvailability: true){groupedEmployees in
					if let employees = groupedEmployees?.first(where: {$0.type == .eligible})?.employees,
						let employeeId = ActiveEmployee.instance?.employee.id,
					   employees.contains(where: {$0 == employeeId}){
						self.listener?.remove()
						self.reference = FirestoreHelper.takeShift(shift){error in
							if let _ = error {
								self.stopLoading(){
									self.showAlert(title: "Oops", message: "Unknown error occured")
								}
								return
							}
							self.shiftId = self.reference?.documentID
							self.stopLoading(){
								self.refreshData()
							}
						}
					} else {
						self.stopLoading(){
							self.showAlert(title: "Oops", message: "You are not eligible to take the shift")
							self.refreshData()
						}
					}
				}
			} else {
				self.showAlert(title: "Oops", message: "Shift has expired")
				refreshData()
			}
		} else if leftActionType == .deny || leftActionType == .offerDeny{
			self.startLoading()
			FirestoreHelper.updateShiftStatus(shift: shift!, status: .declined){ error in
				if let _ = error{
					self.stopLoading(){
						self.showAlert(title: "Oops", message: "Unknown error occured")
					}
					return
				}
				self.stopLoading(){
					self.refreshData()
				}
			}
		} else if leftActionType == .startBreak{
			startTimer()
			self.startLoading()
			FirestoreHelper.startBreak(for: shift!){ error in
				if let _ = error{
					self.stopLoading(){
						self.showAlert(title: "Oops", message: "Unknown error occured")
					}
					return
				}
				self.stopLoading(){
					self.refreshData()
				}
			}
		} else if leftActionType == .endBreak{
			endTimer()
			self.startLoading()
			FirestoreHelper.endBreak(for: shift!){ error in
				if let _ = error{
					self.stopLoading(){
						self.showAlert(title: "Oops", message: "Unknown error occured")
					}
					return
				}
				self.stopLoading(){
					if let shift = self.shift,
						let unpaidBreak = shift.unpaidBreak,
						let totalBreakTime = shift.attendance?.totalBreakTime,
						unpaidBreak < totalBreakTime {
						self.showAlert(title: "Warning", message: "You went above your specified duration for break")
					}
					self.refreshData()
				}
			}
		} else if leftActionType == .offerShift {
			let alert = UIAlertController(title: "Offer Shift", message: "Enter some additional notes for the owner/manager regarding why you want to offer this shift.", preferredStyle: .alert)
			
			self.okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
				self.shift?.offerNotes = alert.textFields![0].text
				self.shift?.offered = true
				if let shift = self.shift{
					self.startLoading()
					FirestoreHelper.offerShift(shift){error in
						if let _ = error{
							self.stopLoading(){
								self.showAlert(title: "Oops", message: "Unknown error occured")
							}
							return
						}
						self.stopLoading(){
							self.refreshData()
						}
					}
					
				}
			})
			
			alert.addTextField { (textField) in
				textField.placeholder = "Notes"
				textField.addTarget(self, action: #selector(self.offerNotesTextFieldChanged(_:)), for: .editingChanged)
				self.okAction?.isEnabled = false
			}
			
			alert.addAction(okAction!)
			
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	@objc func offerNotesTextFieldChanged(_ textfield: UITextField) {
		self.okAction?.isEnabled = (textfield.text?.count ?? 0) > 0
	}
	
	@IBAction func onRightActionButtonPress(_ sender: UIButton) {
		if rightActionType == .approve{
			self.startLoading()
			let employeeId = shift!.employeeId!
			CloudFunctionsHelper.getAssignedHours(employeeIds: [employeeId], shiftDate: shift!.shiftStartDate){
				assignedHours in
				let hours = (assignedHours?.first?.assignedHour ?? 0) + Double(Date.getMinutesDifferenceBetween(start: self.shift!.shiftStartTime, end: self.shift!.shiftEndTime))
				
				let maxHours = ActiveEmployee.instance?.getEmployee(employeeId: employeeId)?.maxHours ?? 40
				
				self.stopLoading(){
					if hours > maxHours{
						self.showConfirmation(title: "Warning", message: "The user will go overtime if you approve this shift. Do you want to process?"){
							completeion()
						}
					} else {
						completeion()
					}
					
					func completeion(){
						FirestoreHelper.updateShiftStatus(shift: self.shift!, status: .approved){ error in
							if let _ = error{
								self.stopLoading(){
									self.showAlert(title: "Oops", message: "Unknown error occured")
								}
								return
							}
							self.stopLoading(){
								self.refreshData()
							}
						}
					}
				}
			}
			
		} else if rightActionType == .offerApprove{
			self.startLoading()
			
			FirestoreHelper.updateShiftStatus(shift: self.shift!, status: .approved){ error in
				if let _ = error{
					self.stopLoading(){
						self.showAlert(title: "Oops", message: "Unknown error occured")
					}
					return
				}
				self.stopLoading(){
					self.refreshData()
				}
			}
			
		} else if rightActionType == .clockIn{
			clockIn()
		} else if rightActionType == .clockOut{
			let clockedOutAt = Date().zeroSeconds
			if let shift = self.shift,
			   shift.shiftEndTime > clockedOutAt {
				let alert = UIAlertController(title: "Warning", message: "You are going to clock out before your shift end time. Do you want to continue?", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
				alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
					completion()
				}))
				self.present(alert, animated: true, completion: nil)
			} else {
				completion()
			}
			func completion(){
				self.startLoading()
				FirestoreHelper.clockOut(for: shift!){ error in
					if let _ = error{
						self.stopLoading(){
							self.showAlert(title: "Oops", message: "Unknown error occured")
						}
						return
					}
					self.stopLoading(){
						self.refreshData()
					}
				}
			}
		}
	}
	
	func clockIn(){
		if locManager.authorizationStatus == .denied {
			self.showAlert(title: "Oops", message: "Location services is denied. Please go to settings and enable location for the app."){
				UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
			}
		} else if let currentLocation = currentLocation  {
			if let branch = ActiveEmployee.instance?.branches.first(where: {$0.id == shift?.branchId}){
				let shiftLocation = CLLocation(latitude: branch.location.latitude, longitude: branch.location.longitude)
				let distance = currentLocation.distance(from: shiftLocation)
				print(distance)
				if distance < 100{
					startTimer()
					self.startLoading()
					FirestoreHelper.clockIn(for: shift!){ error in
						if let _ = error{
							self.stopLoading(){
								self.showAlert(title: "Oops", message: "Unknown error occured")
							}
							return
						}
						self.stopLoading(){
							self.refreshData()
						}
					}
				} else {
					self.showAlert(title: "Oops", message: "You should be within 50 meters radius of the branch where you have been assigned.")
				}
			} else {
				self.showAlert(title: "Oops", message: "Unable to detect your location")
			}
		} else {
			locManager.requestWhenInUseAuthorization()
		}
	}
}

extension ViewShiftVC: UITableViewDelegate, UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
		return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
				
				if let offerNotes = shift.offerNotes{
					cell.offerNoteHeadingLabel.isHidden = false
					cell.offerNoteLabel.isHidden = false
					cell.offerNoteLabel.text = offerNotes
				} else {
					cell.offerNoteHeadingLabel.isHidden = true
					cell.offerNoteLabel.isHidden = true
				}
				
				if let attendance = shift.attendance{
					cell.clockedInLabel.isHidden = false
					cell.clockedInLabel.text = "Clocked In At: " + attendance.clockedInAt.format(to: "EEEE, MMM d, YYYY 'at' hh:mm a")
					
					if let clockedOutAt = attendance.clockedOutAt{
						cell.clockedOutLabel.text = "Clocked Out At: " + clockedOutAt.format(to: "EEEE, MMM d, YYYY 'at' hh:mm a")
					} else {
						cell.clockedOutLabel.isHidden = false
					}
					cell.breakTimeLabel.isHidden = false
					cell.breakTimeLabel.text = "Total Break Time: \(attendance.totalBreakTime) mins"
				} else {
					cell.clockedInLabel.isHidden = true
					cell.clockedOutLabel.isHidden = true
					cell.breakTimeLabel.isHidden = true
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
			} else if isOpenShifts {
					cell.card.title = "Open Shift (\(shift?.noOfOpenShifts ?? 0) remaining)"
					cell.card.barView.backgroundColor = ColorPickerVC.colors.first?.color
					cell.card.setProfileImage(withName: "Open Shift")
					cell.card.rightImageContainer.isHidden = true
			} else {
				let employeeId = shift?.employeeId ?? ""
				let item = ActiveEmployee.instance?.getEmployee(employeeId: employeeId)
				if let employee = item{
					if let profileUrl = employee.profileUrl{
						let (image, _) = UIImage.makeLetterAvatar(withName: employee.name , backgroundColor: UIColor(hex: employee.color))
						cell.card.setProfileImage(withUrl: profileUrl, placeholderImage: image)
					} else {
						cell.card.setProfileImage(withName: employee.name, backgroundColor: employee.color)
					}
				}
				cell.card.title = item?.name
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
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 1{
			let viewController = UIStoryboard(name: "Branch", bundle: nil).instantiateViewController(withIdentifier: "ViewBranchTVC") as! ViewBranchTVC
			viewController.branchId = shift?.branchId
			self.navigationController?.pushViewController(viewController, animated: true)
		} else if indexPath.section == 2 {
			let viewController = UIStoryboard(name: "Role", bundle: nil).instantiateViewController(withIdentifier: "ViewRoleTVC") as! ViewRoleTVC
			viewController.roleId = shift?.roleId
			self.navigationController?.pushViewController(viewController, animated: true)
		} else if indexPath.section == 3 && !isOpenShifts{
			let viewController = UIStoryboard(name: "Employee", bundle: nil).instantiateViewController(withIdentifier: "ViewEmployeeVC") as! ViewEmployeeVC
			viewController.employeeId = shift?.employeeId
			self.navigationController?.pushViewController(viewController, animated: true)
		} else if indexPath.section == 4 {
			let employeeId = shift?.eligibleEmployees?[indexPath.row] ?? ""
			let viewController = UIStoryboard(name: "Employee", bundle: nil).instantiateViewController(withIdentifier: "ViewEmployeeVC") as! ViewEmployeeVC
			viewController.employeeId = employeeId
			self.navigationController?.pushViewController(viewController, animated: true)
		}
	}
}

extension ViewShiftVC: AddShiftDelegate{
	func dismissScreen() {
		navigationController?.popViewController(animated: true)
	}
}

extension ViewShiftVC: CLLocationManagerDelegate{
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if(manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse) {
			currentLocation = manager.location
		}
	}
}

extension ViewShiftVC{
	func startTimer(){
		endTimer()
		updateTime()
		timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
	}
	
	func endTimer(){
		timer?.invalidate()
	}
	
	@objc func updateTime() {
		if let attendance = shift?.attendance {
			if rightActionType == .clockOut {
				let time = Date.getSecondsDifferenceBetween(start: attendance.clockedInAt, end: .now)
				rightActionButton.setTitle("Clock Out - \(secondsToHoursMinutes(time))", for: .normal)
			} else if leftActionType == .endBreak {
				let time = attendance.totalBreakTime * 60
				leftActionButton.setTitle("End Break - \(secondsToHoursMinutes(time))", for: .normal)
			}
		}
		
	}
	func secondsToHoursMinutes(_ seconds: Int) -> String {
		return "\(String(format: "%02d", seconds / 3600)):\(String(format:"%02d", (seconds % 3600) / 60))"
	}
}
