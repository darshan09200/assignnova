//
//  ViewAllBranchTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseFirestore

class ViewAllBranchTVC: UITableViewController {
	
	private let searchController = UISearchController()
	private var branches = [Branch]()
	private var listener: ListenerRegistration?
	override func viewDidLoad() {
		super.viewDidLoad()
		configureSearchBar()
		
		if let businessId = ActiveUser.instance?.business?.id{
			listener = FirestoreHelper.getBranches(businessId: businessId){ branches in
				self.branches = branches ?? []
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
	
	@IBAction func onAddBranchPress(_ sender: UIBarButtonItem) {
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddBranchVC")
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
	
	@IBAction func onShowMapPress(_ sender: UIBarButtonItem) {
	}
	
}

extension ViewAllBranchTVC{
	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return branches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell

		let branch = branches[indexPath.row]
		
		cell.card.barView.backgroundColor = UIColor(hex: branch.color)
		cell.card.title = branch.name
		cell.card.subtitle = branch.address

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let branch = branches[indexPath.row]
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ViewBranchTVC") as! ViewBranchTVC
		viewController.branchId = branch.id
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

extension ViewAllBranchTVC: UISearchBarDelegate{
	
}

extension ViewAllBranchTVC: UISearchControllerDelegate{
	
}

extension ViewAllBranchTVC: UISearchResultsUpdating{
	func updateSearchResults(for searchController: UISearchController) {
		
	}
	
	
}
