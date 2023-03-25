//
//  ViewRoleTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseFirestore

class ViewRoleTVC: UITableViewController {

    
	var roleId: String?
	private var role: Role?
	private var listener: ListenerRegistration?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		listener = FirestoreHelper.getRole(roleId: roleId ?? ""){ role in
			if let role = role{
				self.role = role
				self.tableView.reloadData()
			}
			
		}
		
		tableView.sectionHeaderTopPadding = 0
		
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		listener?.remove()
		
		super.viewDidDisappear(animated)
	}
	@IBAction func onEditPress(_ sender: Any) {
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddRoleVC") as! AddRoleVC
		viewController.isEdit = true
		viewController.role = role
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
}
extension ViewRoleTVC{
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		if section == 0{
			return 1
		}
		return 2
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {return nil}
		return "Employees"
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0{
			let cell = tableView.dequeueReusableCell(withIdentifier: "details", for: indexPath) as! RoleDetailCell
			if let role = role{
				cell.roleName.text = role.name
				cell.roleColor.tintColor = UIColor(hex: role.color)
			}
			return cell
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell
		
		return cell
	}
}
