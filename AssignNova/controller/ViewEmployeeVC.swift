//
//  ViewEmployeeVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-26.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseStorageUI

class ViewEmployeeVC: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	var isProfile = false
	var employeeId: String?
	private var employee: Employee?
	private var listener: ListenerRegistration?
	@IBOutlet weak var editItem: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if isProfile {
			navigationItem.title = "View Profile"
		}
		
		listener = FirestoreHelper.getEmployee(employeeId: employeeId ?? ""){ employee in
			if let employee = employee{
				self.employee = employee
				self.tableView.reloadData()
				
				if !self.isProfile {
					let canEdit = ActionsHelper.canEdit(employee: employee)
					self.editItem.isHidden = !canEdit
				}
			}
		}
		
		tableView.sectionHeaderTopPadding = 0
		tableView.contentInset.bottom = 16
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		listener?.remove()
		
		super.viewDidDisappear(animated)
	}
	
	@IBAction func onEditPress(_ sender: Any) {
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddEmployeeTVC") as! AddEmployeeTVC
		viewController.isEdit = true
		viewController.employee = employee
		viewController.data = AddEmployeeModel(branches: employee?.branches.compactMap{getBranch(branchId: $0)} ?? [], roles: employee?.roles.compactMap{getRole(roleId: $0)} ?? [])
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
	
}

extension ViewEmployeeVC: UITableViewDelegate, UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 || section == 1 {return 1}
		if section == 2 {return max(employee?.branches.count ?? 0 , 1)}
		return max(employee?.roles.count ?? 0 , 1)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0{
			let cell = tableView.dequeueReusableCell(withIdentifier: "avatar", for: indexPath) as! AvatarCell
			
			let (image, _) = UIImage.makeLetterAvatar(withName: employee?.name ?? "", backgroundColor: UIColor(hex: employee?.color ?? ""))
			if let profileUrl = employee?.profileUrl{
				let reference = Storage.storage().reference().child(profileUrl)
				cell.profileImage.sd_imageTransition = .fade
				cell.profileImage.sd_setImage(with: reference, maxImageSize: 1 * 1024 * 1024, placeholderImage: image, options: [.refreshCached])
				
			} else {
				cell.profileImage.image = image
			}
			
			return cell
		} else if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "details", for: indexPath) as! EmployeeDetailsCell
			
			if let employee = employee{
				var showEmpIdPrivatePipe = false
				if let employeeId = employee.employeeId{
					cell.empIdLabel.isHidden = false
					cell.empIdLabel.text = employeeId
					showEmpIdPrivatePipe = true
				} else {
					cell.empIdLabel.isHidden = true
				}
				if employee.isProfilePrivate{
					cell.privateLabel.isHidden = false
				} else {
					showEmpIdPrivatePipe = false
					cell.privateLabel.isHidden = true
				}
				if showEmpIdPrivatePipe{
					cell.empIdPrivatePipe.isHidden = false
				} else {
					cell.empIdPrivatePipe.isHidden = true
				}
				
				cell.nameLabel.text = employee.name
				cell.appRoleLabel.text = employee.appRole.rawValue
				
				cell.emailLabel.text = employee.email
				cell.emailLabel.isHidden = false
				
				if let phoneNumber = employee.phoneNumber, !phoneNumber.isEmpty{
					cell.phoneNumberLabel.text = phoneNumber
					cell.phoneNumberLabel.isHidden = false
					cell.emailPhoneNumberPipe.isHidden = false
				} else {
					cell.phoneNumberLabel.isHidden = true
					cell.emailPhoneNumberPipe.isHidden = true
				}
				
				cell.maxHoursLabel.text = "Max \(employee.maxHours) hours/week"
			}
			
			return cell
		}
		let isEmpty: Bool
		var title: String? = nil
		var subtitle: String? = nil
		var barColor: String? = nil
		if indexPath.section == 2{
			isEmpty = employee?.branches.count == 0
			if !isEmpty{
				let branchId = employee?.branches[indexPath.row]
				if let branch = getBranch(branchId: branchId){
					title = branch.name
					subtitle = branch.address
					barColor = branch.color
				}
			}
		} else {
			isEmpty = employee?.roles.count == 0
			if !isEmpty{
				let roleId = employee?.roles[indexPath.row]
				if let role = getRole(roleId: roleId){
					title = role.name
					subtitle = nil
					barColor = role.color
				}
			}
		}
		if isEmpty || employee == nil{
			let cell = UITableViewCell()
			var configuration = cell.defaultContentConfiguration()
			configuration.text = "No \(indexPath.section == 2 ? "Branch" : "Role") Assigned"
			configuration.textProperties.font = .preferredFont(forTextStyle: .body)
			configuration.textProperties.color = .systemGray
			configuration.textProperties.alignment = .center
			
			cell.contentConfiguration = configuration
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell
			
			cell.card.title = title
			cell.card.subtitle = subtitle
			cell.card.barView.backgroundColor = UIColor(hex: barColor ?? "")
			
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0{return 0}
		return 42
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 2{
			let viewController = UIStoryboard(name: "Branch", bundle: nil).instantiateViewController(withIdentifier: "ViewBranchTVC") as! ViewBranchTVC
			let branchId = employee?.branches[indexPath.row]
			viewController.branchId = branchId
			self.navigationController?.pushViewController(viewController, animated: true)
		} else if indexPath.section == 3 {
			let viewController = UIStoryboard(name: "Role", bundle: nil).instantiateViewController(withIdentifier: "ViewRoleTVC") as! ViewRoleTVC
			let roleId = employee?.roles[indexPath.row]
			viewController.roleId = roleId
			self.navigationController?.pushViewController(viewController, animated: true)
		}
	}
}

extension ViewEmployeeVC{
	func getBranch(branchId: String?)->Branch?{
		return ActiveEmployee.instance?.branches.first(where: {$0.id == branchId})
	}
	
	func getRole(roleId: String?)->Role?{
		return ActiveEmployee.instance?.roles.first(where: {$0.id == roleId})
	}
}
