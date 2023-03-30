//
//  RequestVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-30.
//

import UIKit
import EmptyDataSet_Swift

class RequestVC: UIViewController {

	@IBOutlet weak var requestTypeSegment: UISegmentedControl!
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		tableView.emptyDataSetSource = self
    }
    
	@IBAction func onRequestTypeChanged(_ sender: UISegmentedControl) {
	}
	
}

extension RequestVC: UITableViewDelegate, UITableViewDataSource{
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
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
