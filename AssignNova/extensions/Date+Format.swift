//
//  Date+Format.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-26.
//

import UIKit

extension Date{
	func format(to format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
	static func getMinutesDifferenceBetween(start: Date, end: Date) -> Int{
		
		let diff = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
		
		let hours = diff / 3600
		let minutes = (diff - hours * 3600) / 60
		return minutes
	}
	static func combineDateWithTime(date: Date, time: Date) -> Date {
		let calendar = Calendar.current
		
		let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
		let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
		
		var mergedComponents = DateComponents()
		mergedComponents.year = dateComponents.year
		mergedComponents.month = dateComponents.month
		mergedComponents.day = dateComponents.day
		mergedComponents.hour = timeComponents.hour
		mergedComponents.minute = timeComponents.minute
		mergedComponents.second = timeComponents.second
		
		return calendar.date(from: mergedComponents) ?? date.zeroSeconds
	}
	
	static func buildTimeRangeString(startDate: Date, endDate: Date) -> String {
		
		let startTimeFormatter = DateFormatter()
		startTimeFormatter.dateFormat = "h:mm a"
		
		let endTimeFormatter = DateFormatter()
		endTimeFormatter.dateFormat = "h:mm a"
		
		return String(format: "%@ - %@",
					  startTimeFormatter.string(from: startDate),
					  endTimeFormatter.string(from: endDate))
	}
	
	var zeroSeconds: Date {
		let calendar = Calendar.current
		let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
		return calendar.date(from: dateComponents) ?? self
	}
	
	func getNearest15() -> Date{
		let calendar = Calendar.current
		let comp = calendar.dateComponents([.minute], from: self)
		let remainder = 15 - (comp.minute ?? 0) % 15
		return add(minute: remainder).zeroSeconds
	}
	
	func getLast15() -> Date{
		let calendar = Calendar.current
		let comp = calendar.dateComponents([.minute], from: self)
		let remainder =  (comp.minute ?? 0) % 15
		return add(minute: -remainder).zeroSeconds
	}
	
	func add(minute: Int) -> Date{
		let calendar = Calendar.current
		return calendar.date(byAdding: .minute, value: minute, to: self) ?? self
	}
	
	func add(days: Int) -> Date{
		let calendar = Calendar.current
		return calendar.date(byAdding: .day, value: days, to: self) ?? self
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
	
	var startOfMonth: Date {
		return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
	}
	
	var endOfMonth: Date {
		return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth)!
	}
	
	func startOfWeek(using calendar: Calendar = .gregorian) -> Date {
		calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
	}
	
	var startOfWeek: Date {
		let gregorian = Calendar(identifier: .gregorian)
		return gregorian.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
	}
	
	var endOfWeek: Date {
		let gregorian = Calendar(identifier: .gregorian)
		let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
		return gregorian.date(byAdding: .day, value: 7, to: sunday)!
	}
	
	var dayOfTheWeek: Int {
		let dayNumber = Calendar.current.component(.weekday, from: self)
		return dayNumber - 1
	}
}

extension Calendar {
	static let gregorian = Calendar(identifier: .gregorian)
}
