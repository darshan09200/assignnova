//
//  TimeOff.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-30.
//

import UIKit
import FirebaseFirestoreSwift

struct TimeOff: Codable{
	@DocumentID var id: String?
	var businessId: String
	var employeeId: String
	var startDate: Date
	var endDate: Date?
	var startTime: Date?
	var endTime: Date?
	var isAllDay: Bool
	var notes: String?
	var status: Status = .pending
	var acceptedBy: String?{
		didSet{
			acceptedOn = .now
		}
	}
	var acceptedOn: Date?
	@ServerTimestamp var createdOn: Date?

	init(id: String? = nil, startDate: Date, endDate: Date? = nil, startTime: Date? = nil, endTime: Date? = nil, isAllDay: Bool, notes: String? = nil) {
		self.id = id
		self.startDate = startDate
		self.endDate = endDate
		if let startTime = startTime{
			self.startTime = Date.combineDateWithTime(date: startDate, time: startTime)
		}
		if let endTime = endTime{
			self.endTime = Date.combineDateWithTime(date: endTime, time: endTime)
		}
		self.isAllDay = isAllDay
		self.notes = notes

		self.employeeId = ActiveEmployee.instance?.employee.id ?? ""
		self.businessId = ActiveEmployee.instance?.employee.businessId ?? ""
	}
}
