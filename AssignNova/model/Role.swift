//
//  Role.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseAuth

struct Role: Codable{
	@DocumentID var id: String?
	var name: String
	var businessId: String
	var color: String
	var createdBy: String
	@ServerTimestamp var createdAt: Date?
	@ServerTimestamp var updatedAt: Date?
	
	init(id: String? = nil, name: String, businessId: String, color: String, createdAt: Date? = nil, updatedAt: Date? = nil) {
		self.id = id
		self.name = name
		self.businessId = businessId
		self.color = color
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		
		self.createdBy = Auth.auth().currentUser?.uid ?? ""
	}
}
