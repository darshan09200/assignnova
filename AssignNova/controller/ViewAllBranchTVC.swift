//
//  ViewAllBranchTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseFirestore
import EmptyDataSet_Swift

class ViewAllBranchTVC: UITableViewController {

	private let searchController = UISearchController()
	private var branches = [Branch]()
	private var filteredBranches = [Branch]()
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
			listener = FirestoreHelper.getBranches(businessId: businessId){ branches in
				self.branches = branches ?? []
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

	@IBAction func onAddBranchPress(_ sender: UIBarButtonItem) {
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddBranchVC")
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}

	@IBAction func onShowMapPress(_ sender: UIBarButtonItem) {
	}

}

extension ViewAllBranchTVC{

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredBranches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell

		let branch = filteredBranches[indexPath.row]

		cell.card.barView.backgroundColor = UIColor(hex: branch.color)
		cell.card.title = branch.name
		cell.card.subtitle = branch.address

        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let branch = filteredBranches[indexPath.row]
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ViewBranchTVC") as! ViewBranchTVC
		viewController.branchId = branch.id
		self.navigationController?.pushViewController(viewController, animated: true)
	}

}

extension ViewAllBranchTVC: UISearchResultsUpdating{
	func updateSearchResults(for searchController: UISearchController) {
		filterData()
	}
	
	func filterData() {
		if searchText.isEmpty {
			filteredBranches = branches
		} else {
			filteredBranches = branches.filter{
				$0.name.lowercased().contains(
					searchText) ||
				$0.address.lowercased().contains(searchText)
				
			}
		}
		tableView.reloadData()
	}
	
}

extension ViewAllBranchTVC: EmptyDataSetSource{
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let message = NSMutableAttributedString(string: searchText.isEmpty ? "No Branches Found" : "Try finding a different branch.", attributes: [
			.font: UIFont.preferredFont(forTextStyle: .body)
		])
		return message
	}
}
