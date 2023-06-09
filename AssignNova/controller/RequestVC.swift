//
//  RequestVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-30.
//

import UIKit
import EmptyDataSet_Swift
import FirebaseFirestore

struct GroupedTimeOff{
	var status: Status
	var timeOffs: [TimeOff]
}

struct GroupedOpenShift{
	var status: Status
	var shifts: [Shift]
}

class RequestVC: UIViewController {

	@IBOutlet weak var addRequestButton: UIBarButtonItem!
	@IBOutlet weak var requestTypeSegment: UISegmentedControl!

	@IBOutlet weak var tableView: UITableView!

	private var listener: ListenerRegistration?
	private var groupedTimeOffs = [GroupedTimeOff]()
	private var groupedOpenShifts = [GroupedOpenShift]()

	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		tableView.emptyDataSetSource = self
		tableView.sectionHeaderTopPadding = 0

		fetchData()
		
		addRequestButton.isHidden = !ActionsHelper.isTrialActive()
    }

	func fetchData(){
		if let employeeId = ActiveEmployee.instance?.employee.id{
			listener?.remove()
			if requestTypeSegment.selectedSegmentIndex == 0{
				listener = FirestoreHelper.getTimeOffs(employeeId: employeeId){ timeOffs in
					if let timeOffs = timeOffs, timeOffs.count > 0{
						var groupedTimeOffs = [Status.pending, Status.approved, Status.declined].compactMap{GroupedTimeOff(status: $0, timeOffs: [])}
						for timeOff in timeOffs {
							let index = groupedTimeOffs.firstIndex{$0.status == timeOff.status}
							if let index = index{
								groupedTimeOffs[index].timeOffs.append(timeOff)
							}
						}
						self.groupedTimeOffs = groupedTimeOffs
					} else {
						self.groupedTimeOffs = []
					}
					self.tableView.reloadData()
				}
			} else if requestTypeSegment.selectedSegmentIndex == 1 {
				listener = FirestoreHelper.getOpenShifts(employeeId: employeeId){ openShifts in
					if let openShifts = openShifts, openShifts.count > 0{
						var groupedOpenShifts = [Status.requested, Status.approved, Status.declined].compactMap{GroupedOpenShift(status: $0, shifts: [])}
						for openShift in openShifts {
							let index = groupedOpenShifts.firstIndex{$0.status == openShift.status}
							if let index = index{
								groupedOpenShifts[index].shifts.append(openShift)
							}
						}
						self.groupedOpenShifts = groupedOpenShifts
					} else {
						self.groupedOpenShifts = []
					}
					self.tableView.reloadData()
				}
			} else {
				listener = FirestoreHelper.getOfferdShifts(employeeId: employeeId){ openShifts in
					if let openShifts = openShifts, openShifts.count > 0{
						var groupedOpenShifts = [Status.requested, Status.approved, Status.declined].compactMap{GroupedOpenShift(status: $0, shifts: [])}
						for openShift in openShifts {
							let index = groupedOpenShifts.firstIndex{$0.status == openShift.offerStatus}
							if let index = index{
								groupedOpenShifts[index].shifts.append(openShift)
							}
						}
						self.groupedOpenShifts = groupedOpenShifts
					} else {
						self.groupedOpenShifts = []
					}
					self.tableView.reloadData()
				}
			}
		}
	}

	@IBAction func onRequestTypeChanged(_ sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 0 {
			addRequestButton.isHidden = !ActionsHelper.isTrialActive()
		} else {
			addRequestButton.isHidden = true
		}
		fetchData()
	}

	@IBAction func onAddRequestButtonPress(_ sender: Any) {

		let viewController = UIStoryboard(name: "TimeOff", bundle: nil).instantiateViewController(withIdentifier: "AddTimeOffVC") as! AddTimeOffVC

		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
	
	func getController(for indexPath: IndexPath) -> UIViewController?{
		if requestTypeSegment.selectedSegmentIndex == 0 && groupedTimeOffs.count > 0 && groupedTimeOffs[indexPath.section].timeOffs.count > 0{
			let item = groupedTimeOffs[indexPath.section].timeOffs[indexPath.row]
			let viewController = UIStoryboard(name: "TimeOff", bundle: nil).instantiateViewController(withIdentifier: "ViewTimeOffVC") as! ViewTimeOffVC
			viewController.timeOffId = item.id
			return viewController
		} else if groupedOpenShifts.count > 0 && groupedOpenShifts[indexPath.section].shifts.count > 0 {
			let item = groupedOpenShifts[indexPath.section].shifts[indexPath.row]
			let viewController = UIStoryboard(name: "Shift", bundle: nil).instantiateViewController(withIdentifier: "ViewShiftVC") as! ViewShiftVC
			viewController.shiftId = item.id
			return viewController
		}
		return nil
	}
}

extension RequestVC: UITableViewDelegate, UITableViewDataSource{

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if requestTypeSegment.selectedSegmentIndex == 0{
			return max(groupedTimeOffs[section].timeOffs.count, 1)
		}
		return max(groupedOpenShifts[section].shifts.count, 1)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if requestTypeSegment.selectedSegmentIndex == 0{
			return groupedTimeOffs.count
		}
		return groupedOpenShifts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "card") as! CardCell
		if requestTypeSegment.selectedSegmentIndex == 0{
			if groupedTimeOffs[indexPath.section].timeOffs.count == 0{
				let cell = UITableViewCell()
				
				var configuration = cell.defaultContentConfiguration()
				configuration.text = "No \(groupedTimeOffs[indexPath.section].status.rawValue) Time Off Requests Found"
				configuration.textProperties.font = .preferredFont(forTextStyle: .body)
				configuration.textProperties.color = .systemGray
				configuration.textProperties.alignment = .center
				
				cell.contentConfiguration = configuration
				cell.selectionStyle = .none
				return cell
			}
			let item = groupedTimeOffs[indexPath.section].timeOffs[indexPath.row]
			let employee = ActiveEmployee.instance?.getEmployee(employeeId: item.employeeId)
			cell.card.title = employee?.name
			cell.card.subtitle = item.startDate.format(to: "EEE, MMM dd, yyyy")
			if let employee = employee{
				if let profileUrl = employee.profileUrl{
					let (image, _) = UIImage.makeLetterAvatar(withName: employee.name , backgroundColor: UIColor(hex: employee.color))
					cell.card.setProfileImage(withUrl: profileUrl, placeholderImage: image)
				} else {
					cell.card.setProfileImage(withName: employee.name, backgroundColor: employee.color)
				}
			}
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
			if groupedOpenShifts[indexPath.section].shifts.count == 0{
				let cell = UITableViewCell()
				
				var configuration = cell.defaultContentConfiguration()
				configuration.text = "No \(groupedOpenShifts[indexPath.section].status.rawValue) Open Shifts Requests Found"
				configuration.textProperties.font = .preferredFont(forTextStyle: .body)
				configuration.textProperties.color = .systemGray
				configuration.textProperties.alignment = .center
				
				cell.contentConfiguration = configuration
				cell.selectionStyle = .none
				return cell
			}
			let item = groupedOpenShifts[indexPath.section].shifts[indexPath.row]
			let employee = ActiveEmployee.instance?.getEmployee(employeeId: item.employeeId!)
			cell.card.title = employee?.name
			cell.card.subtitle = item.shiftStartDate.format(to: "EEE, MMM dd, yyyy")
			if let employee = employee{
				if let profileUrl = employee.profileUrl{
					let (image, _) = UIImage.makeLetterAvatar(withName: employee.name , backgroundColor: UIColor(hex: employee.color))
					cell.card.setProfileImage(withUrl: profileUrl, placeholderImage: image)
				} else {
					cell.card.setProfileImage(withName: employee.name, backgroundColor: employee.color)
				}
			}
			
			let status = indexPath.section == 1 ? item.status : item.offerStatus
			if status == .approved{
				cell.card.titleImageView.isHidden = false
				cell.card.titleImageView.image = UIImage(systemName: "checkmark.circle.fill")
				cell.card.titleImageView.tintColor = .systemGreen
			} else if status == .declined{
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

		if requestTypeSegment.selectedSegmentIndex == 0{
			header.sectionTitle.text = groupedTimeOffs[section].status.rawValue
		} else {
			header.sectionTitle.text = groupedOpenShifts[section].status.rawValue
		}

		return header.contentView
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let controller = getController(for: indexPath) else {return}
		self.navigationController?.pushViewController(controller, animated: true)
	}

	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let controller = getController(for: indexPath) else {return nil}
		return UIContextMenuConfiguration(
			identifier: indexPath as NSIndexPath,
			previewProvider: {
				return controller
			})
		
	}
	
	func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		guard let destinationViewController = animator.previewViewController else {
			return
		}
		
		animator.addAnimations {
			self.show(destinationViewController, sender: self)
		}
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
