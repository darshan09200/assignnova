//
//  TimeOff.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-30.
//

import UIKit
import FirebaseFirestoreSwift

struct TimeOff{
	@DocumentID var id: String?
	var businessId: String
	var employeeId: String
	var shiftStartDate: Date
	var shiftEndDate: Date?
	var shiftStartTime: Date?
	var shiftEndTime: Date?
	var isAllDay: Bool
	var notes: String?
}
