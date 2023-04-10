//
//  EmployeePickerVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit
import EmptyDataSet_Swift
import FirebaseFirestore

protocol EmployeePickerDelegate{
	func onSelectEmployees(employees: [Employee])
	func onCancelEmployeePicker()
}

class EmployeePickerVC: UIViewController {
	
	var delegate: EmployeePickerDelegate?
	
	@IBOutlet weak var tableView: UITableView!
	var employees = [Employee]()
	var selectedEmployees = [Employee]()
	private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		tableView.emptyDataSetSource = self
		
//		if let businessId = ActiveEmployee.instance?.business?.id{
//			listener = FirestoreHelper.getEmployees(businessId: businessId){ employees in
//				self.employees = employees ?? []
//				self.tableView.reloadData()
//
//				for (index, employee) in self.employees.enumerated(){
//					if self.selectedEmployees.contains(where: {$0.id ==  employee.id}){
//						self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
//					}
//				}
//			}
//		}
    }
	
	static func getController(delegate: EmployeePickerDelegate, employees: [Employee], selectedEmployees: [Employee]? = nil) -> UINavigationController {
		let employeePickerController = UIStoryboard(name: "EmployeePicker", bundle: nil)
			.instantiateViewController(withIdentifier: "EmployeePickerVC") as! EmployeePickerVC
		
		employeePickerController.delegate = delegate
		employeePickerController.employees = employees
		employeePickerController.selectedEmployees = selectedEmployees ?? [Employee]()
		
		let navController = UINavigationController(rootViewController: employeePickerController)
		return navController
	}

	@IBAction func onCancelPress(_ sender: Any) {
		delegate?.onCancelEmployeePicker()
		dismiss(animated: true)
	}
	
	@IBAction func onDonePress(_ sender: Any) {
		let selectedEmployees = tableView.indexPathsForSelectedRows?.compactMap{employees[$0.row]} ?? []
		delegate?.onSelectEmployees(employees: selectedEmployees)
		dismiss(animated: true)
	}
}

extension EmployeePickerVC: UITableViewDelegate, UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return employees.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "card") as! CardCell
		cell.cardCellType = .selection
		let item = employees[indexPath.row]
		cell.card.title = item.name
		if let profileUrl = item.profileUrl{
			let (image, _) = UIImage.makeLetterAvatar(withName: item.name , backgroundColor: UIColor(hex: item.color))
			cell.card.setProfileImage(withUrl: profileUrl, placeholderImage: image)
		} else {
			cell.card.setProfileImage(withName: item.name, backgroundColor: item.color)
		}
		cell.card.barView.backgroundColor = UIColor(hex: item.color)
		return cell
	}
	
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		let item = employees[indexPath.row]
//		delegate?.onSelectEmployee(employee: item)
//		dismiss(animated: true)
//	}
}

extension EmployeePickerVC: EmptyDataSetSource{
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let message = NSMutableAttributedString(string: "No Eligible Employees Found for the shift", attributes: [
			.font: UIFont.preferredFont(forTextStyle: .body)
		])
		return message
	}
}
