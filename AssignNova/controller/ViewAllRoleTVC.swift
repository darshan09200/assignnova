//
//  ViewAllRoleTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseFirestore
import EmptyDataSet_Swift

class ViewAllRoleTVC: UITableViewController {

	private let searchController = UISearchController()
	private var roles = [Role]()
	private var filteredRoles = [Role]()
	private var listener: ListenerRegistration?
	
	var searchText: String{
		(
			searchController.searchBar.text?
				.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		).lowercased()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureSearchBar()

		tableView.emptyDataSetSource = self
		if let businessId = ActiveEmployee.instance?.business?.id{
			listener = FirestoreHelper.getRoles(businessId: businessId){ roles in
				self.roles = roles ?? []
				self.filterData()
				self.tableView.reloadData()
			}
		}
	}

	private func configureSearchBar() {
		navigationItem.searchController = searchController
		searchController.obscuresBackgroundDuringPresentation = false
		definesPresentationContext = true
		searchController.searchResultsUpdater = self
	}

	@IBAction func onAddRolePress(_ sender: UIBarButtonItem) {
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddRoleVC")
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}

}

extension ViewAllRoleTVC{

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredRoles.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell

		let role = filteredRoles[indexPath.row]

		cell.card.barView.backgroundColor = UIColor(hex: role.color)
		cell.card.title = role.name

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let role = filteredRoles[indexPath.row]
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ViewRoleTVC") as! ViewRoleTVC
		viewController.roleId = role.id
		self.navigationController?.pushViewController(viewController, animated: true)
	}

}

extension ViewAllRoleTVC: UISearchResultsUpdating{
	func updateSearchResults(for searchController: UISearchController) {
		filterData()
	}
	
	func filterData() {
		if searchText.isEmpty {
			filteredRoles = roles
		} else {
			filteredRoles = roles.filter{
				$0.name.lowercased().contains(
					searchText)
				
			}
		}
		tableView.reloadData()
	}
	
}

extension ViewAllRoleTVC: EmptyDataSetSource{
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let message = NSMutableAttributedString(string: searchText.isEmpty ? "No Roles Found" : "Try finding a different role.", attributes: [
			.font: UIFont.preferredFont(forTextStyle: .body)
		])
		return message
	}
}
