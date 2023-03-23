//
//  ActiveEmployee.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseAuth

struct ActiveEmployee{
	public static var instance: ActiveEmployee? = nil
	var business: Business?
	var employee: Employee
//	var branches: [Branch]?
}
