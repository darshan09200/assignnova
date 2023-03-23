//
//  Employee.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-19.
//

import UIKit
import FirebaseFirestoreSwift

enum AppRole: String, Codable {
	case owner
	case manager
	case shiftSupervisor
	case employee
}

struct Employee: Codable{
	@DocumentID var id: String?
	var userId: String?
	var businessId: String
	var employeeId: String?
	var firstName: String
	var lastName: String
	var appRole: AppRole
	var maxHours: Double = 40
	var isProfilePrivate = false
	var profileUrl: String?
	@ServerTimestamp var updatedAt: Date?
	
	init(id: String? = nil, userId: String? = nil, employeeId: String? = nil, firstName: String, lastName: String, appRole: AppRole = .employee, maxHours: Double = 40, isProfilePrivate: Bool = false, profileUrl: String? = nil, updatedAt: Date? = nil) {
		self.id = id
		self.userId = userId
		self.employeeId = employeeId
		self.firstName = firstName
		self.lastName = lastName
		self.appRole = appRole
		self.maxHours = maxHours
		self.isProfilePrivate = isProfilePrivate
		self.profileUrl = profileUrl
		self.updatedAt = updatedAt
		
		self.businessId = ActiveEmployee.instance?.business?.id ?? ""
	}
}
