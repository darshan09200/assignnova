//
//  SecondViewController.swift
//  AssignNova
//
//  Created by simran mehra on 2023-03-20.
//

import UIKit

class BranchMapListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var searchBar: UISearchBar!
	let data = [
		"Location 1",
		"Location 1",
		"Location 1",
		"Location 1",
		"Location 1",
		"Location 1"
	]
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		searchBar.showsScopeBar = true
		searchBar.scopeButtonTitles = ["Map Area", "All"]
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 20
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell
		cell.card.title = "Location \(indexPath.row)"
		return cell
	}
		
}

extension BranchMapListVC: UISearchBarDelegate{
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		print(selectedScope)
	}
}
