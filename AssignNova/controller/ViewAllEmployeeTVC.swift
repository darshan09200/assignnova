//
//  ViewAllEmployeeTVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-25.
//

import UIKit
import FirebaseFirestore
import EmptyDataSet_Swift

class ViewAllEmployeeTVC: UITableViewController {
	
	private let searchController = UISearchController()
	private var employees = [Employee]()
	private var filteredEmployees = [Employee]()
	private var listener: ListenerRegistration?
	@IBOutlet weak var addEmployeeItem: UIBarButtonItem!
	
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
		if let businessId = ActiveEmployee.instance?.employee.businessId{
			listener = FirestoreHelper.getEmployees(businessId: businessId){ employees in
				self.employees = employees ?? []
				self.filterData()
				self.tableView.reloadData()
				
				let canAdd = ActionsHelper.canAdd()
				
				self.addEmployeeItem.isHidden = !canAdd
			}
		}
	}
	
	private func configureSearchBar() {
		navigationItem.searchController = searchController
		searchController.obscuresBackgroundDuringPresentation = false
		definesPresentationContext = true
		searchController.searchResultsUpdater = self
	}
	
	@IBAction func onAddEmployeePress(_ sender: Any) {
		if let noOfEmployees = ActiveEmployee.instance?.business?.noOfEmployees,
			let employeeCount = ActiveEmployee.instance?.employees.count {
			if employeeCount < noOfEmployees {
				let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddEmployeeTVC") as! AddEmployeeTVC
				self.present(UINavigationController(rootViewController: viewController), animated: true)
			} else {
				self.showAlert(title: "Oops", message: "You have reached the maximum number of employees you can add. Please ask the owner to increase it in the settings if you want to add more.")
			}
		}
	}
}

extension ViewAllEmployeeTVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEmployees.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! CardCell
		
		let employee = filteredEmployees[indexPath.row]
		
		cell.card.barView.backgroundColor = UIColor(hex: employee.color)
		let name = "\(employee.firstName) \(employee.lastName)"
		cell.card.title = name
		if let profileUrl = employee.profileUrl{
			let (image, _) = UIImage.makeLetterAvatar(withName: employee.name , backgroundColor: UIColor(hex: employee.color))
			cell.card.setProfileImage(withUrl: profileUrl, placeholderImage: image)
		} else {
			cell.card.setProfileImage(withName: employee.name, backgroundColor: employee.color)
		}
		cell.card.rightIcon = UIImage(systemName: "chevron.right")
		
		return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let employee = filteredEmployees[indexPath.row]
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ViewEmployeeVC") as! ViewEmployeeVC
		viewController.employeeId = employee.id
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}

extension ViewAllEmployeeTVC: UISearchResultsUpdating{
	func updateSearchResults(for searchController: UISearchController) {
		filterData()
	}
	
	func filterData() {
		if searchText.isEmpty {
			filteredEmployees = employees
		} else {
			filteredEmployees = employees.filter{
				$0.name.lowercased().contains(
					searchText)
				
			}
		}
		tableView.reloadData()
	}
	
}

extension ViewAllEmployeeTVC: EmptyDataSetSource{
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let message = NSMutableAttributedString(string: searchText.isEmpty ? "No Employees Found" : "Try finding a different employee.", attributes: [
			.font: UIFont.preferredFont(forTextStyle: .body)
		])
		return message
	}
}
