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
}
