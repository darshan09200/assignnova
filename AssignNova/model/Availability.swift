//
//  Availability.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-10.
//

import UIKit
import FirebaseFirestoreSwift

struct Availability: Codable{
	@DocumentID var id: String?
	var businessId: String
	var employeeId: String
	var allDay = false
	var isAvailable = true
	var date: Date
	var startTime: Date
	var endTime: Date
	var createdBy: String
	var notes: String?
	@ServerTimestamp var createdAt: Date?
	@ServerTimestamp var updatedAt: Date?
	
	init(id: String? = nil, allDay: Bool = false, isAvailable: Bool = true, date: Date, startTime: Date, endTime: Date, notes: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
		self.id = id
		self.allDay = allDay
		self.isAvailable = isAvailable
		self.date = date
		self.startTime = Date.combineDateWithTime(date: date, time: startTime)
		self.endTime = Date.combineDateWithTime(date: date, time: endTime)
		self.notes = notes
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		
		self.businessId = ActiveEmployee.instance?.employee.businessId ?? ""
		self.employeeId = ActiveEmployee.instance?.employee.id ?? ""
		self.createdBy = ActiveEmployee.instance?.employee.id ?? ""
	}
}

