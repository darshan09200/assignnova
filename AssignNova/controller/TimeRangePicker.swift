//
//  TimeRangePicker.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-26.
//

import UIKit

class TimeRangePicker: NSObject {
	
	
	static var startTimes = setStartTimes()
	static var endTimes = setEndTimes()
	
	static let timeFormatter = DateFormatter()
	
	
	static func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}

	static func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch component {
			case 0:
				return startTimes.count
			case 1:
				return endTimes.count
			default:
				return 0
		}
	}

	static func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch component {
			case 0:
				return getTimeString(from: startTimes[row])
			case 1:
				return getTimeString(from: endTimes[row])
			default:
				return nil
		}
	}
	
	static func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)->(Date, Date)? {

		let startTimeIndex = pickerView.selectedRow(inComponent: 0)
		let endTimeIndex = pickerView.selectedRow(inComponent: 1)

		guard startTimes.indices.contains(startTimeIndex),
			  endTimes.indices.contains(endTimeIndex) else { return nil }

		var startTime = startTimes[startTimeIndex]
		var endTime = endTimes[endTimeIndex]

		let diffMinutes = Int(endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970) / 60
		
		if diffMinutes < 15 {
			var dateComponent = DateComponents()
			if component == 0 {
				dateComponent.minute = 15
				let correctedTime = Calendar.current.date(byAdding: dateComponent, to: startTime)
				if let correctedTime = correctedTime, let index = endTimes.firstIndex(of: correctedTime){
					pickerView.selectRow(index , inComponent: 1, animated: true)
					endTime = correctedTime
				}
			} else {
				dateComponent.minute = -15
				let correctedTime = Calendar.current.date(byAdding: dateComponent, to: endTime)
				if let correctedTime = correctedTime, let index = startTimes.firstIndex(of: correctedTime){
					pickerView.selectRow(index, inComponent: 0, animated: true)
					startTime = correctedTime
				}
			}
		}
		
		return (startTime, endTime)

	}
	
	// MARK: - Private helpers
	
	static private func getTimes(of date: Date) -> [Date] {
		var times = [Date]()
		var currentDate = date
		
		currentDate = Calendar.current.date(bySetting: .hour, value: 00, of: currentDate)!
		currentDate = Calendar.current.date(bySetting: .minute, value: 00, of: currentDate)!
		times.append(currentDate)
		let calendar = Calendar.current
		
		let interval = 15
		var nextDiff = interval - calendar.component(.minute, from: currentDate) % interval
		var nextDate = calendar.date(byAdding: .minute, value: nextDiff, to: currentDate) ?? Date()
		
		var hour = Calendar.current.component(.hour, from: nextDate)
		var minute = Calendar.current.component(.minute, from: nextDate)
		
		while(hour == 00 ? minute != 00 : hour > 00) {
			times.append(nextDate)
			
			nextDiff = interval - calendar.component(.minute, from: nextDate) % interval
			nextDate = calendar.date(byAdding: .minute, value: nextDiff, to: nextDate) ?? Date()
			
			hour = Calendar.current.component(.hour, from: nextDate)
			minute = Calendar.current.component(.minute, from: nextDate)
		}
		
		return times
	}
	
	static private func setStartTimes() -> [Date] {
		let today = Date()
		return getTimes(of: today)
	}
	
	static private func setEndTimes() -> [Date] {
		let today = Date()
		return getTimes(of: today)
	}
	
	static private func getTimeString(from: Date) -> String {
		timeFormatter.timeStyle = .short
		return timeFormatter.string(from: from)
	}
	
}

extension Date {
	
	static func buildTimeRangeString(startDate: Date, endDate: Date) -> String {
		
		let startTimeFormatter = DateFormatter()
		startTimeFormatter.dateFormat = "h:mm a"
		
		let endTimeFormatter = DateFormatter()
		endTimeFormatter.dateFormat = "h:mm a"
		
		return String(format: "%@ - %@",
					  startTimeFormatter.string(from: startDate),
					  endTimeFormatter.string(from: endDate))
	}
	
	func getNearest15() -> Date{
		let calendar = Calendar.current
		let comp = calendar.dateComponents([.minute], from: self)
		let remainder = 15 - (comp.minute ?? 0) % 15
		return add(minute: remainder)
	}
	
	func add(minute: Int) -> Date{
		let calendar = Calendar.current
		return calendar.date(byAdding: .minute, value: minute, to: self) ?? self
	}
	
	var startOfDay: Date {
		return Calendar.current.startOfDay(for: self)
	}
	
	var endOfDay: Date {
		var components = DateComponents()
		components.day = 1
		components.second = -1
		return Calendar.current.date(byAdding: components, to: startOfDay)!
	}
}
