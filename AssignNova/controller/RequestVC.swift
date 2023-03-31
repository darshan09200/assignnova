//
//  RequestVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-30.
//

import UIKit
import EmptyDataSet_Swift
import FirebaseFirestore

class RequestVC: UIViewController {

	@IBOutlet weak var addRequestButton: UIBarButtonItem!
	@IBOutlet weak var requestTypeSegment: UISegmentedControl!
	
	@IBOutlet weak var tableView: UITableView!
	
	private var listener: ListenerRegistration?
	private var timeOffs = [TimeOff]()
	private var openShifts = [Shift]()
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		tableView.emptyDataSetSource = self
		tableView.sectionHeaderTopPadding = 0
		
		fetchData()
    }
	
	func fetchData(){
		if let employeeId = ActiveEmployee.instance?.employee.id{
			listener?.remove()
			if requestTypeSegment.selectedSegmentIndex == 0{
				listener = FirestoreHelper.getTimeOffs(employeeId: employeeId){ timeOffs in
					self.timeOffs = timeOffs ?? []
					self.tableView.reloadData()
				}
			} else {
				listener = FirestoreHelper.getOpenShifts(employeeId: employeeId){ openShifts in
					self.openShifts = openShifts ?? []
					self.tableView.reloadData()
				}
			}
		}
	}
    
	@IBAction func onRequestTypeChanged(_ sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 0 {
			addRequestButton.isHidden = false
		} else {
			addRequestButton.isHidden = true
		}
		fetchData()
	}
	
	@IBAction func onAddRequestButtonPress(_ sender: Any) {
		
		let viewController = UIStoryboard(name: "TimeOff", bundle: nil).instantiateViewController(withIdentifier: "AddTimeOffVC") as! AddTimeOffVC
		
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
}

extension RequestVC: UITableViewDelegate, UITableViewDataSource{
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if requestTypeSegment.selectedSegmentIndex == 0{
			return timeOffs.count
		}
		return openShifts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "card") as! CardCell
		if requestTypeSegment.selectedSegmentIndex == 0{
			let item = timeOffs[indexPath.row]
			cell.card.title = ActiveEmployee.instance?.getEmployee(employeeId: item.employeeId)?.name
			cell.card.subtitle = item.shiftStartDate.format(to: "EEE, MMM dd, yyyy")
			
			if item.status == .approved{
				cell.card.titleImageView.isHidden = false
				cell.card.titleImageView.image = UIImage(systemName: "checkmark.circle.fill")
				cell.card.titleImageView.tintColor = .systemGreen
			} else if item.status == .declined{
				cell.card.titleImageView.isHidden = false
				cell.card.titleImageView.image = UIImage(systemName: "x.circle.fill")
				cell.card.titleImageView.tintColor = .systemRed
			} else {
				cell.card.titleImageView.isHidden = true
			}
			
			print(cell.card.titleImageView.isHidden)
		} else {
			let item = openShifts[indexPath.row]
			cell.card.title = ActiveEmployee.instance?.getEmployee(employeeId: item.employeeId!)?.name
			cell.card.subtitle = item.shiftStartDate.format(to: "EEE, MMM dd, yyyy")
			if item.status == .approved{
				cell.card.titleImageView.isHidden = false
				cell.card.titleImageView.image = UIImage(systemName: "checkmark.circle.fill")
				cell.card.titleImageView.tintColor = .systemGreen
			} else if item.status == .declined{
				cell.card.titleImageView.isHidden = false
				cell.card.titleImageView.image = UIImage(systemName: "x.circle")
				cell.card.titleImageView.tintColor = .systemRed
			} else {
				cell.card.titleImageView.isHidden = true
			}
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableCell(withIdentifier: "header") as! SectionHeaderCell
		
		header.sectionTitle.text = "Pending"
		
		return header.contentView
	}
	
}

extension RequestVC: EmptyDataSetSource{
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let message = NSMutableAttributedString(
			string: requestTypeSegment.selectedSegmentIndex == 0 ? "No Time Off Requests Found" : "No Open Shifts Request Found",
			attributes: [.font: UIFont.preferredFont(forTextStyle: .body)]
		)
		return message
	}
}
