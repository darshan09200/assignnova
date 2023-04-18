//
//  Employee.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-19.
//

import UIKit
import FirebaseFirestoreSwift

enum AppRole: String, CaseIterable, Codable {
	case owner = "Owner"
	case manager = "Manager"
	case shiftSupervisor = "Shift Supervisor"
	case employee = "Employee"
	
	var index: Int { AppRole.allCases.firstIndex(of: self) ?? 0 }
	
	static var selectCases: [AppRole]{
		AppRole.allCases.filter{$0 != .owner}
	}
}

extension CaseIterable where Self: Equatable {
	
	var index: Self.AllCases.Index? {
		return Self.allCases.firstIndex { self == $0 }
	}
}

struct Employee: Codable{
	@DocumentID var id: String?
	var userId: String?
	var businessId: String
	var employeeId: String?
	var firstName: String
	var lastName: String
	var name: String{
		"\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
	}
	var appRole: AppRole
	var maxHours: Double = 40
	var isProfilePrivate = false
	var profileUrl: String?
	var email: String
	var phoneNumber: String?
	var invited: Bool?
	var branches = [String]()
	var roles = [String]()
	var color: String
	var fcmToken: [String]?
	var createdBy: String
	var isActive: Bool?
	var customerId: String?
	@ServerTimestamp var createdAt: Date?
	@ServerTimestamp var updatedAt: Date?
	
	init(id: String? = nil, userId: String? = nil, employeeId: String? = nil, firstName: String, lastName: String, appRole: AppRole, maxHours: Double = 40, isProfilePrivate: Bool = false, profileUrl: String? = nil, email: String, phoneNumber: String? = nil, invited: Bool? = nil, branches: [String] = [String](), roles: [String] = [String](), color: String, fcmToken: [String]? = nil, createdAt: Date? = nil) {
		self.id = id
		self.userId = userId
		self.employeeId = employeeId
		self.firstName = firstName
		self.lastName = lastName
		self.appRole = appRole
		self.maxHours = maxHours
		self.isProfilePrivate = isProfilePrivate
		self.profileUrl = profileUrl
		self.email = email.lowercased()
		self.phoneNumber = phoneNumber
		self.invited = invited
		self.branches = branches
		self.roles = roles
		self.color = color
		self.fcmToken = fcmToken
		self.createdAt = createdAt
		
		self.createdBy = ActiveEmployee.instance?.employee.userId ?? ""
		self.businessId = ActiveEmployee.instance?.employee.businessId ?? ""

	}
}
