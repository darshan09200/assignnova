//
//  AssignedHour.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-08.
//

import UIKit

struct AssignedHoursRequest: Codable{
	var employeeIds: [String]
	var shiftDate: TimeInterval
}

struct AssignedHoursResponse: Codable{
	var assignedHours: [AssignedHour]
	
}

struct AssignedHour: Codable{
	var employeeId: String
	var assignedHour: Double
}

