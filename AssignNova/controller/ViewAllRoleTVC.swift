//
//  ViewAllRoleTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseFirestore

class ViewAllRoleTVC: UITableViewController {

	private let searchController = UISearchController()
	private var roles = [Role]()
	private var listener: ListenerRegistration?
	override func viewDidLoad() {
		super.viewDidLoad()
		configureSearchBar()

		if let businessId = ActiveEmployee.instance?.business?.id{
			listener = FirestoreHelper.getRoles(businessId: businessId){ roles in
				self.roles = roles ?? []
				self.tableView.reloadData()
			}
		}
	}

	private func configureSearchBar() {
		navigationItem.searchController = searchController
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.delegate = self
		searchController.delegate = self
		definesPresentationContext = true
		searchController.searchResultsUpdater = self
	}

	@IBAction func onAddRolePress(_ sender: UIBarButtonItem) {
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddRoleVC")
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}

}

extension ViewAllRoleTVC{
	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return roles.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell

		let role = roles[indexPath.row]

		cell.card.barView.backgroundColor = UIColor(hex: role.color)
		cell.card.title = role.name

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let role = roles[indexPath.row]
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ViewRoleTVC") as! ViewRoleTVC
		viewController.roleId = role.id
		self.navigationController?.pushViewController(viewController, animated: true)
	}

	/*
	 // Override to support editing the table view.
	 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
	 if editingStyle == .delete {
	 // Delete the row from the data source
	 tableView.deleteRows(at: [indexPath], with: .fade)
	 } else if editingStyle == .insert {
	 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	 }
	 }
	 */

}

extension ViewAllRoleTVC: UISearchBarDelegate{

}

extension ViewAllRoleTVC: UISearchControllerDelegate{

}

extension ViewAllRoleTVC: UISearchResultsUpdating{
	func updateSearchResults(for searchController: UISearchController) {

	}


}
