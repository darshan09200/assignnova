//
//  ApprovalStatus.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-31.
//

import UIKit

enum Status: String, CaseIterable, Codable {
	case requested = "Requested"
	case pending = "Pending"
	case approved = "Approved"
	case declined = "Declined"
}
