//
//  BranchPickerVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit
import EmptyDataSet_Swift

protocol BranchPickerDelegate{
	func onSelectBranch(branch: Branch)
	func onCancelBranchPicker()
}

class BranchPickerVC: UIViewController {
	
	var delegate: BranchPickerDelegate?
	
	@IBOutlet weak var tableView: UITableView!
	var branches = ActiveEmployee.instance?.branches ?? [Branch]()
	
	var selectedBranch: Branch?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		tableView.emptyDataSetSource = self
    }
	
	static func getController(delegate: BranchPickerDelegate, selectedBranch: Branch?) -> UINavigationController {
		let branchPickerController = UIStoryboard(name: "BranchPicker", bundle: nil)
			.instantiateViewController(withIdentifier: "BranchPickerVC") as! BranchPickerVC
		
		branchPickerController.delegate = delegate
		branchPickerController.selectedBranch = selectedBranch
		
		let navController = UINavigationController(rootViewController: branchPickerController)
		return navController
	}

	@IBAction func onCancelPress(_ sender: Any) {
		delegate?.onCancelBranchPicker()
		dismiss(animated: true)
	}
}

extension BranchPickerVC: UITableViewDelegate, UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return branches.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "card") as! CardCell
		cell.cardCellType = .selection
		let item = branches[indexPath.row]
		cell.card.title = item.name
		cell.card.subtitle = item.address
		cell.card.barView.backgroundColor = UIColor(hex: item.color)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let item = branches[indexPath.row]
		delegate?.onSelectBranch(branch: item)
		dismiss(animated: true)
	}
}

extension BranchPickerVC: EmptyDataSetSource{
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let message = NSMutableAttributedString(string: "No Records Found", attributes: [
			.font: UIFont.preferredFont(forTextStyle: .body)
		])
		return message
	}
}
