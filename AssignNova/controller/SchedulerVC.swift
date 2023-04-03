//
//  SchedulerVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-26.
//

import UIKit
import FSCalendar
import EmptyDataSet_Swift
import FirebaseFirestore

struct WeekDay{
	let date: Date
	var shifts: [Shift]
}

class SchedulerVC: UIViewController {

	@IBOutlet weak var monthLabel: UILabel!
	
	@IBOutlet weak var calendar: FSCalendar!
	@IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var shiftTypeSegment: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!
	
	var listener: ListenerRegistration?
	
	var shiftType: ShiftType {
		switch self.shiftTypeSegment.selectedSegmentIndex{
			case 1:
				return .openShift
			case 2:
				return .allShift
			default:
				return .myShift
		}
	}
	
	lazy var previousSelectedDate: Date? = calendar.selectedDate
	
	var selectedDate: Date {
		calendar.selectedDate!
	}
	
	var firstDayOfWeek: Date {
		selectedDate.startOfWeek()
	}
	
	var week: [Date]{
		(0...6).reduce(into: []) { result, daysToAdd in
			result.append(Calendar.current.date(byAdding: .day, value: daysToAdd, to: firstDayOfWeek))
		}
		.compactMap { $0 }
	}
	
	var groupedShifts = [WeekDay]()
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		calendar.today = nil;
		calendar.register(DayCell.self, forCellReuseIdentifier: "cell")
		calendar.select(.now)
		calendar.scope = .week
		calendar.calendarHeaderView.isHidden = true
		calendar.headerHeight = 0
		calendar.appearance.titleDefaultColor = .label
		calendar.appearance.eventDefaultColor = UIColor(named: "AccentColor")
		calendar.appearance.eventSelectionColor = .white
		calendar.appearance.borderRadius = 0.2
		calendar.appearance.titleSelectionColor = .white
		calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
		calendar.appearance.eventOffset = CGPoint(x: 0, y: -4)
		calendar.appearance.weekdayTextColor = UIColor(named: "AccentColor")
		calendar.appearance.weekdayFont = .preferredFont(forTextStyle: .body)
		calendar.placeholderType = .fillHeadTail
		
		tableView.sectionHeaderTopPadding = 0
		
		tableView.emptyDataSetSource = self
		
		refreshData()
		
		refreshMonthLabel()
		monthLabel.isHidden = true
    }
    
	func refreshData(){
		previousSelectedDate = selectedDate
		groupedShifts = []
        if let businessId = ActiveEmployee.instance?.employee.businessId{
			listener?.remove()
			listener = FirestoreHelper.getShifts(businessId: businessId, startDate: week.first!, endDate: week.last!, shiftType: shiftType){ shifts in
				if let shifts = shifts, shifts.count > 0{
					var data = self.week.compactMap{WeekDay(date: $0, shifts: [])}
					for shift in shifts{
						let index = self.week.firstIndex(where: {Calendar.current.compare($0, to: shift.shiftStartDate, toGranularity: .day) == .orderedSame})
						if let index = index{
							data[index].shifts.append(shift)
						}
					}
					self.groupedShifts = data
				} else {
					self.groupedShifts = []
				}
				self.tableView.reloadData()
				self.calendar.reloadData()
				self.tableView.layoutIfNeeded()
				if self.groupedShifts.count > 0{
					self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.selectedDate.dayOfTheWeek), at: .top, animated: true)
				}
				
			}
		}
	}
	
	@IBAction func onShiftTypeChanged(_ sender: Any) {
		refreshData()
	}
	@IBAction func onCalendarTogglePress(_ sender: Any) {
		if calendar.scope == .week{
			monthLabel.isHidden = false
			calendar.setScope(.month, animated: true)
		} else {
			monthLabel.isHidden = true
			calendar.setScope(.week, animated: true)
		}
	}
	
	@IBAction func onAddPress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Shift", bundle: nil).instantiateViewController(withIdentifier: "AddShiftTVC") as! AddShiftTVC
		
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
	
	func getController(for indexPath: IndexPath) -> UIViewController?{
		if groupedShifts.count > 0 && groupedShifts[indexPath.section].shifts.count > 0{
			let shift = groupedShifts[indexPath.section].shifts[indexPath.row]
			let viewController = UIStoryboard(name: "Shift", bundle: nil).instantiateViewController(withIdentifier: "ViewShiftVC") as! ViewShiftVC
			viewController.shiftId = shift.id
			return viewController
		}
		return nil
	}
	
	func refreshMonthLabel(){
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM YYYY"
		monthLabel.text = formatter.string(from: selectedDate)
	}
	
}

extension SchedulerVC: UITableViewDelegate, UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		if groupedShifts.count > 0{ return 7}
		return 0
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if groupedShifts.count > 0{
			return max(groupedShifts[section].shifts.count, 1)
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if groupedShifts[indexPath.section].shifts.count == 0{
			let cell = UITableViewCell()
			
			var configuration = cell.defaultContentConfiguration()
			configuration.text = "No Shift Found"
			configuration.textProperties.font = .preferredFont(forTextStyle: .body)
			configuration.textProperties.color = .systemGray
			configuration.textProperties.alignment = .center
			
			cell.contentConfiguration = configuration
			cell.selectionStyle = .none
			return cell
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "card") as! CardCell
		let shift = groupedShifts[indexPath.section].shifts[indexPath.row]
		cell.card.title = Date.buildTimeRangeString(startDate: shift.shiftStartTime, endDate: shift.shiftEndTime)
		var employeeName = "Open Shift"
		if let employeeId = shift.employeeId{
			let employee = ActiveEmployee.instance?.getEmployee(employeeId: employeeId)
			if let employee = employee{
				employeeName = employee.name
				if let profileUrl = employee.profileUrl{
					cell.card.setProfileImage(withUrl: profileUrl)
				} else {
					cell.card.setProfileImage(withName: employee.name, backgroundColor: employee.color)
				}
			}
		} else {
			cell.card.setProfileImage(withName: employeeName)
		}
		var roleName: String = ""
		if let role = ActiveEmployee.instance?.getRole(roleId: shift.roleId){
			roleName = "as \(role.name)"
		}
		cell.card.subtitle = "\(employeeName) \(roleName)"
		cell.card.barView.backgroundColor = UIColor(hex: shift.color)
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableCell(withIdentifier: "header") as! SectionHeaderCell
		
		let date = week[section]
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE, MMM d"
		
		header.sectionTitle.text = dateFormatter.string(from: date)
		
		return header.contentView
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let viewController = getController(for: indexPath){
			self.navigationController?.pushViewController(viewController, animated: true)
		}
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

extension SchedulerVC: FSCalendarDataSource, FSCalendarDelegate{
	
	func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
		self.calendarHeightConstraint.constant = bounds.height
		self.view.layoutIfNeeded()
	}
	
	func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
		let index = self.week.firstIndex(where: {Calendar.current.compare($0, to: date, toGranularity: .day) == .orderedSame})
		if let index = index, groupedShifts.count > 0 && groupedShifts[index].shifts.count > 0{
			return 1
		}
		return 0
	}
	
	func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
		return true
	}
	
	func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
		return false
	}
	
	func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
		let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
		return cell
	}
	
	func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
		calendar.select(calendar.currentPage)
		self.configureVisibleCells()
		refreshData()
		refreshMonthLabel()
	}
	
	func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
		self.configure(cell: cell, for: date, at: position)
	}
	
	func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
		self.configureVisibleCells()
		if calendar.scope == .week{
			if groupedShifts.count > 0{
				tableView.scrollToRow(at: IndexPath(row: 0, section: date.dayOfTheWeek), at: .top, animated: true)
			}
		} else if previousSelectedDate?.startOfWeek() != selectedDate.startOfWeek(){
			print("called")
			refreshData()
		}
	}
	
	private func configureVisibleCells() {
		calendar.visibleCells().forEach { (cell) in
			let date = calendar.date(for: cell)
			let position = calendar.monthPosition(for: cell)
			self.configure(cell: cell, for: date!, at: position)
		}
	}
	
	private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
		
		let dayCell = (cell as! DayCell)
		if calendar.selectedDates.contains(date) {
			dayCell.selectionLayer.isHidden = false
		} else {
			dayCell.selectionLayer.isHidden = true
		}
		dayCell.setNeedsLayout()
	}
}


extension Calendar {
	static let gregorian = Calendar(identifier: .gregorian)
}
extension Date {
	func startOfWeek(using calendar: Calendar = .gregorian) -> Date {
		calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
	}

	var dayOfTheWeek: Int {
		let dayNumber = Calendar.current.component(.weekday, from: self)
		return dayNumber - 1
	}
}


extension SchedulerVC: EmptyDataSetSource{
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let message = NSMutableAttributedString(string: "No Shifts Found", attributes: [
			.font: UIFont.preferredFont(forTextStyle: .body)
		])
		return message
	}
}
