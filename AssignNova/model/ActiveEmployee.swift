//
//  ActiveEmployee.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ActiveEmployee{
	public static var instance: ActiveEmployee? = nil
	
	var branchListener: ListenerRegistration?
	var roleListener: ListenerRegistration?
	var employeeListener: ListenerRegistration?
	
	var employee: Employee
	
	var business: Business?{
		didSet{
			if let businessId = business?.id{
				branchListener = FirestoreHelper.getBranches(businessId: businessId){ branches in
					if let branches = branches{
						self.branches = branches
					}
				}

				roleListener = FirestoreHelper.getRoles(businessId: businessId){ roles in
					if let roles = roles{
						self.roles = roles
					}
				}
				
				employeeListener = FirestoreHelper.getEmployees(businessId: businessId){ employees in
					if let employees = employees{
						self.employees = employees
					}
				}
			}
		}
	}
	
	var branches = [Branch]()
	var roles = [Role]()
	var employees = [Employee]()
	
	init(business: Business? = nil, employee: Employee, branches: [Branch] = [Branch](), roles: [Role] = [Role]()) {
		self.business = business
		self.employee = employee
		self.branches = branches
		self.roles = roles
	}
	
	deinit {
		branchListener?.remove()
		roleListener?.remove()
	}
	
	func getBranch(branchId: String)->Branch?{
		return branches.first(where: {$0.id == branchId})
	}
	
	func getRole(roleId: String)->Role?{
		return roles.first(where: {$0.id == roleId})
	}
	
	func getEmployee(employeeId: String)->Employee?{
		return employees.first(where: {$0.id == employeeId})
	}
}
