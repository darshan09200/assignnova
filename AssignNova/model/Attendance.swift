//
//  Attendance.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-02.
//

import UIKit

struct Attendance: Codable{
	var clockedInAt: Date
	var clockedOutAt: Date?
	var breaks = [Break]()
	var totalBreakTime: Int{
		return breaks.reduce(0) {
			$0 + Date.getMinutesDifferenceBetween(start: $1.start, end: $1.end ?? .now)
		}
	}
}

struct Break: Codable{
	var start: Date
	var end: Date?
}
