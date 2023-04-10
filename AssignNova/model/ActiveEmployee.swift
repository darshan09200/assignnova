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
	static var fcmToken: String?
	public static var instance: ActiveEmployee? = nil{
		didSet{
			if instance != nil {
				FirestoreHelper.registerFCMToken()
			}
		}
	}
	
	var branchListener: ListenerRegistration?
	var roleListener: ListenerRegistration?
	var employeeListener: ListenerRegistration?
	
    var employee: Employee
	
	var business: Business?
	
	var branches = [Branch]()
	var roles = [Role]()
	var employees = [Employee]()
	
	var subscriptionDetail: SubscriptionDetail?
	
    var factOfTheDay = Facts.randomElement()
	
	var isFetchingSubscription = true
	
	init(business: Business? = nil, employee: Employee, branches: [Branch] = [Branch](), roles: [Role] = [Role]()) {
		self.business = business
		self.employee = employee
		self.branches = branches
		self.roles = roles
		
		CloudFunctionsHelper.getSubscriptionDetails(){ subscriptionDetail in
			self.isFetchingSubscription = false
			self.subscriptionDetail = subscriptionDetail
			NotificationCenter.default.post(name: Notification.Name("getSubscriptionDetails"), object: nil)
		}
        
        self.branchListener = FirestoreHelper.getBranches(businessId: employee.businessId){ branches in
            if let branches = branches{
                self.branches = branches
				NotificationCenter.default.post(name: Notification.Name("getBranches"), object: nil)
            }
        }

        self.roleListener = FirestoreHelper.getRoles(businessId: employee.businessId){ roles in
            if let roles = roles{
                self.roles = roles
				NotificationCenter.default.post(name: Notification.Name("getRoles"), object: nil)
            }
        }
        
        self.employeeListener = FirestoreHelper.getEmployees(businessId: employee.businessId){ employees in
            if let employees = employees{
                self.employees = employees
				NotificationCenter.default.post(name: Notification.Name("getEmployees"), object: nil)
            }
        }
	}
	
	deinit {
		branchListener?.remove()
		roleListener?.remove()
        employeeListener?.remove()
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
