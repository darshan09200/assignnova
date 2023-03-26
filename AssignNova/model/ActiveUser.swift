//
//  ActiveUser.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseAuth

struct ActiveUser{
	public static var instance: ActiveUser? = nil
	var business: Business?
	var user: User
//	var branches: [Branch]?
}
