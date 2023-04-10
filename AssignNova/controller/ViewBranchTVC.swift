//
//  ViewBrancTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import SDWebImage
import FirebaseFirestore

class ViewBranchTVC: UITableViewController {
	
	var branchId: String?
	private var branch: Branch?
	private var listener: ListenerRegistration?
	
	@IBOutlet weak var editBranchItem: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		listener = FirestoreHelper.getBranch(branchId: branchId ?? ""){ branch in
			if let branch = branch{
				self.branch = branch
				self.tableView.reloadData()
				
				let canEdit = ActionsHelper.canEdit(branch: branch)
				self.editBranchItem.isHidden = !canEdit
			}
			
		}
		
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		listener?.remove()
		
		super.viewDidDisappear(animated)
	}
	
	@IBAction func onEditPress(_ sender: Any) {
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddBranchVC") as! AddBranchVC
		viewController.isEdit = true
		viewController.branch = branch
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
}
extension ViewBranchTVC{

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
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
			let cell = tableView.dequeueReusableCell(withIdentifier: "details", for: indexPath) as! BranchDetailCell
			if let branch = branch{
				cell.branchName.text = branch.name
				cell.branchColor.tintColor = UIColor(hex: branch.color)
				cell.branchAddress.text = branch.address
				if let apiKey = ProcessInfo.processInfo.environment["MAPS_API_KEY"]{
					var baseUrl = URL(string: "https://maps.googleapis.com/maps/api/staticmap")
					baseUrl?.appendQueryItem(name: "zoom", value: "15")
					baseUrl?.appendQueryItem(name: "size", value: "300x300")
					baseUrl?.appendQueryItem(name: "scale", value: "2")
					baseUrl?.appendQueryItem(name: "markers", value: "label:\(branch.name.first)|\(branch.location.latitude), \(branch.location.longitude)")
					baseUrl?.appendQueryItem(name: "key", value: apiKey)
					cell.branchMapImage.sd_setImage(with: baseUrl)
				}
			}
			return cell
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell
		
		return cell
    }
}

extension URL {
	
	mutating func appendQueryItem(name: String, value: String?) {
		
		guard var urlComponents = URLComponents(string: absoluteString) else { return }
		
		// Create array of existing query items
		var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
		
		// Create query item
		let queryItem = URLQueryItem(name: name, value: value)
		
		// Append the new query item in the existing query items array
		queryItems.append(queryItem)
		
		// Append updated query items array in the url component object
		urlComponents.queryItems = queryItems
		
		// Returns the url from new url components
		self = urlComponents.url!
	}
}
