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
	var shiftStartDate: Date
	var shiftEndDate: Date?
	var shiftStartTime: Date?
	var shiftEndTime: Date?
	var isAllDay: Bool
	var notes: String?
	var status: Status = .pending
	@ServerTimestamp var createdOn: Date?
	
	init(id: String? = nil, shiftStartDate: Date, shiftEndDate: Date? = nil, shiftStartTime: Date? = nil, shiftEndTime: Date? = nil, isAllDay: Bool, notes: String? = nil) {
		self.id = id
		self.shiftStartDate = shiftStartDate
		self.shiftEndDate = shiftEndDate
		self.shiftStartTime = shiftStartTime
		self.shiftEndTime = shiftEndTime
		self.isAllDay = isAllDay
		self.notes = notes
		
		self.employeeId = ActiveEmployee.instance?.employee.id ?? ""
		self.businessId = ActiveEmployee.instance?.employee.businessId ?? ""
	}
}

