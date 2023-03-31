//
//  Shift.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-27.
//

import UIKit
import FirebaseFirestoreSwift

struct Shift: Codable{
	@DocumentID var id: String?
	var businessId: String
	var shiftStartDate: Date
	var shiftStartTime: Date
	var shiftEndTime: Date
	var unpaidBreak: Int?
	var branchId: String
	var roleId: String
	var color: String
	var notes: String?
	var employeeId: String?
	var eligibleEmployees: [String]?
	var noOfOpenShifts: Int?
	var approvalRequired: Bool = false
	var status: Status?
	@ServerTimestamp var updatedAt: Date?
	
	init(id: String? = nil, shiftStartDate: Date, shiftStartTime: Date, shiftEndTime: Date, unpaidBreak: Int? = nil, branchId: String, roleId: String, color: String, notes: String? = nil, employeeId: String? = nil, eligibleEmployees: [String]? = nil, noOfOpenShifts: Int? = nil, updatedAt: Date? = nil) {
		self.id = id
		self.shiftStartDate = shiftStartDate
		self.shiftStartTime = shiftStartTime
		self.shiftEndTime = shiftEndTime
		self.unpaidBreak = unpaidBreak
		self.branchId = branchId
		self.roleId = roleId
		self.color = color
		self.notes = notes
		self.employeeId = employeeId
		self.eligibleEmployees = eligibleEmployees
		self.noOfOpenShifts = noOfOpenShifts
		self.updatedAt = updatedAt
		
		self.businessId = ActiveEmployee.instance?.employee.businessId ?? ""
		
		if eligibleEmployees != nil{
			approvalRequired = true
		}
	}
}
