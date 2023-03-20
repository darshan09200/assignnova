//
//  User.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-19.
//

import UIKit
import FirebaseFirestoreSwift

struct User: Codable{
	@DocumentID var id: String?
	var firstName: String
	var lastName: String
	@ServerTimestamp var updatedAt: Date?
}
