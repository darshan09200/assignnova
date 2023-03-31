//
//  ViewAllEmployeeTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-25.
//

import UIKit
import FirebaseFirestore

class ViewAllEmployeeTVC: UITableViewController {
	
	private let searchController = UISearchController()
	private var employees = [Employee]()
	private var listener: ListenerRegistration?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureSearchBar()
		
		if let businessId = ActiveEmployee.instance?.employee.businessId{
			listener = FirestoreHelper.getEmployees(businessId: businessId){ employees in
				self.employees = employees ?? []
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
	
	@IBAction func onAddEmployeePress(_ sender: Any) {
		let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddEmployeeTVC") as! AddEmployeeTVC
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
}

extension ViewAllEmployeeTVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell
		
		let employee = employees[indexPath.row]
		
		cell.card.barView.backgroundColor = .clear
		let name = "\(employee.firstName) \(employee.lastName)"
		cell.card.title = name
		cell.card.profileAvatarContainer.isHidden = false
		let (image, _) = UIImage.makeLetterAvatar(withName: name, backgroundColor: UIColor(hex: employee.color))
		cell.card.profileAvatar.image = image
		cell.card.rightIcon = UIImage(systemName: "chevron.right")
		
		return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let employee = employees[indexPath.row]
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ViewEmployeeVC") as! ViewEmployeeVC
		viewController.employeeId = employee.id
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


extension ViewAllEmployeeTVC: UISearchBarDelegate{
	
}

extension ViewAllEmployeeTVC: UISearchControllerDelegate{
	
}

extension ViewAllEmployeeTVC: UISearchResultsUpdating{
	func updateSearchResults(for searchController: UISearchController) {
		
	}
	
	
}
