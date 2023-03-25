//
//  RolePickerVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit
import EmptyDataSet_Swift

protocol RolePickerDelegate{
	func onSelectRole(role: Role)
	func onCancelRolePicker()
}

class RolePickerVC: UIViewController {
	
	var delegate: RolePickerDelegate?
	
	@IBOutlet weak var tableView: UITableView!
	var roles = ActiveEmployee.instance?.roles ?? [Role]()
	
	var selectedRole: Role?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		tableView.emptyDataSetSource = self
    }
	
	static func getController(delegate: RolePickerDelegate, selectedRole: Role?) -> UINavigationController {
		let rolePickerController = UIStoryboard(name: "RolePicker", bundle: nil)
			.instantiateViewController(withIdentifier: "RolePickerVC") as! RolePickerVC
		
		rolePickerController.delegate = delegate
		rolePickerController.selectedRole = selectedRole
		
		let navController = UINavigationController(rootViewController: rolePickerController)
		return navController
	}

	@IBAction func onCancelPress(_ sender: Any) {
		delegate?.onCancelRolePicker()
		dismiss(animated: true)
	}
}

extension RolePickerVC: UITableViewDelegate, UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return roles.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "card") as! CardCell
		cell.cardCellType = .selection
		let item = roles[indexPath.row]
		cell.card.title = item.name
		cell.card.barView.backgroundColor = UIColor(hex: item.color)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let item = roles[indexPath.row]
		delegate?.onSelectRole(role: item)
		dismiss(animated: true)
	}
}


extension RolePickerVC: EmptyDataSetSource{
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let message = NSMutableAttributedString(string: "No Records Found", attributes: [
			.font: UIFont.preferredFont(forTextStyle: .body)
		])
		return message
	}
}
