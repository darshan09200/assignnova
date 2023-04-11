//
//  ViewAllAvailabilityVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-26.
//

import UIKit
import FSCalendar
import EmptyDataSet_Swift
import FirebaseFirestore

struct AvailabilityWeekDay{
	let date: Date
	var availabilities: [Availability]
}


class ViewAllAvailabilityVC: UIViewController {

	@IBOutlet weak var monthLabel: UILabel!
	
	@IBOutlet weak var calendar: FSCalendar!
	@IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var tableView: UITableView!
	
	var listener: ListenerRegistration?
	
	lazy var previousSelectedDate: Date? = calendar.selectedDate
	
	var selectedDate: Date {
		calendar.selectedDate!
	}
	
	var dateGroup: [Date]{
		let startDate = selectedDate.startOfMonth.startOfWeek
		let endDate = selectedDate.endOfMonth.endOfWeek
		let length = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 30
		
		return (0...length).reduce(into: []) { result, daysToAdd in
			result.append(Calendar.current.date(byAdding: .day, value: daysToAdd, to: startDate))
		}
		.compactMap { $0 }
	}
	
	var groupedAvailabilities = [AvailabilityWeekDay]()
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		calendar.today = nil;
		calendar.register(DayCell.self, forCellReuseIdentifier: "cell")
		calendar.select(.now)
		calendar.scope = .month
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
    }
    
	func refreshData(){
		previousSelectedDate = selectedDate
		groupedAvailabilities = []
        if let businessId = ActiveEmployee.instance?.employee.businessId{
			listener?.remove()
			listener = FirestoreHelper.getAvailbilities(startDate: dateGroup.first!, endDate: dateGroup.last!){ availabilities in
				var data = self.dateGroup.compactMap{AvailabilityWeekDay(date: $0, availabilities: [])}
				for availability in availabilities ?? []{
					let index = self.dateGroup.firstIndex(where: {Calendar.current.compare($0, to: availability.date, toGranularity: .day) == .orderedSame})
					if let index = index{
						data[index].availabilities.append(availability)
					}
				}
				self.groupedAvailabilities = data
				
				self.tableView.reloadData()
				self.calendar.reloadData()
				self.tableView.layoutIfNeeded()
				if self.groupedAvailabilities.count > 0{
					let index = self.dateGroup.firstIndex(where: {Calendar.current.compare($0, to: self.selectedDate, toGranularity: .day) == .orderedSame})
					self.tableView.scrollToRow(at: IndexPath(row: 0, section: index ?? 0), at: .top, animated: true)
				}
				
			}
		}
	}
	
	@IBAction func onAddPress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Shift", bundle: nil).instantiateViewController(withIdentifier: "AddShiftTVC") as! AddShiftTVC
		viewController.data.selectedDate = selectedDate > .now.startOfDay ? selectedDate : .now.startOfDay
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
	
	func getController(for indexPath: IndexPath) -> UIViewController?{
		if groupedAvailabilities.count > 0 && groupedAvailabilities[indexPath.section].availabilities.count > 0{
			let availability = groupedAvailabilities[indexPath.section].availabilities[indexPath.row]
			let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddAvailabilityVC") as! AddAvailabilityVC
			viewController.availability = availability
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

extension ViewAllAvailabilityVC: UITableViewDelegate, UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		return groupedAvailabilities.count
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if groupedAvailabilities.count > 0{
			return max(groupedAvailabilities[section].availabilities.count, 1)
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if groupedAvailabilities[indexPath.section].availabilities.count == 0{
			let cell = UITableViewCell()
			
			var configuration = cell.defaultContentConfiguration()
			configuration.text = "No Availability Found"
			configuration.textProperties.font = .preferredFont(forTextStyle: .body)
			configuration.textProperties.color = .systemGray
			configuration.textProperties.alignment = .center
			
			cell.contentConfiguration = configuration
			cell.selectionStyle = .none
			return cell
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "card") as! CardCell
		let availability = groupedAvailabilities[indexPath.section].availabilities[indexPath.row]
		let availableLabel = availability.isAvailable ? "Available": "Unavailable"
		if availability.allDay{
			cell.card.title = "\(availableLabel) All Day"
		} else {
			cell.card.title = "\(availableLabel) \(Date.buildTimeRangeString(startDate: availability.startTime, endDate: availability.endTime))"
		}
		if availability.isAvailable{
			cell.card.barView.backgroundColor = .systemGreen
		} else {
			cell.card.barView.backgroundColor = .systemGray
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableCell(withIdentifier: "header") as! SectionHeaderCell
		if dateGroup.count < section {return nil}
		let date = dateGroup[section]
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE, MMM d"
		
		header.sectionTitle.text = dateFormatter.string(from: date)
		if date > .now.add(days: 14).endOfDay{
			header.rightButton?.isHidden = false
			header.rightButton?.date = date
			header.rightButton?.addTarget(self, action: #selector(onAddAvailabilityPress(_:)), for: .touchUpInside)
		} else {
			header.rightButton?.isHidden = true
		}
		
		return header.contentView
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let viewController = getController(for: indexPath){
			self.present(UINavigationController(rootViewController: viewController), animated: true)
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
			self.present(UINavigationController(rootViewController: destinationViewController), animated: true)
		}
	}
	
}

extension ViewAllAvailabilityVC: FSCalendarDataSource, FSCalendarDelegate{
	
	func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
		self.calendarHeightConstraint.constant = bounds.height
		self.view.layoutIfNeeded()
	}
	
	func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
		let index = self.dateGroup.firstIndex(where: {Calendar.current.compare($0, to: date, toGranularity: .day) == .orderedSame})
		if let index = index, groupedAvailabilities.count > 0 && groupedAvailabilities[index].availabilities.count > 0{
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
		if !dateGroup.contains(previousSelectedDate ?? .now.startOfDay) || (calendar.scope == .month && monthPosition != .current){
			calendar.setCurrentPage(date, animated: true)
			calendar.select(date)
			refreshData()
		} else if groupedAvailabilities.count > 0{
			let index = self.dateGroup.firstIndex(where: {Calendar.current.compare($0, to: date, toGranularity: .day) == .orderedSame})
			tableView.scrollToRow(at: IndexPath(row: 0, section: index ?? 0), at: .top, animated: true)
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

extension ViewAllAvailabilityVC: EmptyDataSetSource{
	func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
		let message = NSMutableAttributedString(string: "No Shifts Found", attributes: [
			.font: UIFont.preferredFont(forTextStyle: .body)
		])
		return message
	}
}

extension ViewAllAvailabilityVC{
	@objc func onAddAvailabilityPress(_ sender: AddAvailabilityButton){
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddAvailabilityVC") as! AddAvailabilityVC
		
		viewController.startDate = sender.date ?? .now
		
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
}
