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
	var attendance: Attendance?
	var offered: Bool?
	var offerStatus: Status?
	var offerNotes: String?
	
	var isActive: Bool {
		ActiveEmployee.instance?.branches.contains(where: {$0.id == branchId}) ?? false && ActiveEmployee.instance?.roles.contains(where: {$0.id == roleId}) ?? false
	}
	var acceptedBy: String?{
		didSet{
			acceptedOn = .now
		}
	}
	var acceptedOn: Date?
	var createdBy: String
	@ServerTimestamp var createdAt: Date?
	@ServerTimestamp var updatedAt: Date?
	
	init(id: String? = nil, shiftStartDate: Date, shiftStartTime: Date, shiftEndTime: Date, unpaidBreak: Int? = nil, branchId: String, roleId: String, color: String, notes: String? = nil, employeeId: String? = nil, eligibleEmployees: [String]? = nil, noOfOpenShifts: Int? = nil, updatedAt: Date? = nil) {
		self.id = id
		self.shiftStartDate = Date.combineDateWithTime(date: shiftStartDate, time: shiftStartTime)
		self.shiftStartTime = Date.combineDateWithTime(date: shiftStartDate, time: shiftStartTime)
		self.shiftEndTime = Date.combineDateWithTime(date: shiftStartDate, time: shiftEndTime)
		self.unpaidBreak = unpaidBreak
		self.branchId = branchId
		self.roleId = roleId
		self.color = color
		self.notes = notes
		self.employeeId = employeeId
		self.eligibleEmployees = eligibleEmployees
		self.noOfOpenShifts = noOfOpenShifts
		self.updatedAt = updatedAt
		
		self.createdBy = ActiveEmployee.instance?.employee.id ?? ""
		self.businessId = ActiveEmployee.instance?.employee.businessId ?? ""
		
		if eligibleEmployees != nil{
			approvalRequired = true
		}
	}
}
