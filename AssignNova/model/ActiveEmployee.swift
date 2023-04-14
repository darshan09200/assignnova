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
			if let instance = instance {
				FirestoreHelper.registerFCMToken()
				if let employeeId = instance.employee.id{
					Keychain.save(key: "employeeId", data: Data(from: employeeId))					
				}
				instance.refreshInvoices()
			} else {
				Keychain.delete(key: "employeeId")
			}
		}
	}
	
	var businessListener: ListenerRegistration?
	var branchListener: ListenerRegistration?
	var roleListener: ListenerRegistration?
	var employeeListener: ListenerRegistration?
	
	var employee: Employee
	
	var business: Business?
	var allBranches = [Branch]()
	var branches: [Branch]{
		allBranches.filter{$0.isActive ?? true}
	}
	
	var allRoles = [Role]()
	var roles: [Role]{
		allRoles.filter{$0.isActive ?? true}
	}
	
	var allEmployees = [Employee]()
	var employees: [Employee]{
		allEmployees.filter{$0.isActive ?? true}
	}
	
	var subscriptionDetail: SubscriptionDetail?
	
    var factOfTheDay = Facts.randomElement()
	
	var isFetchingSubscription = true
	
	var invoices: [Invoice]?
	
	init(business: Business? = nil, employee: Employee, branches: [Branch] = [Branch](), roles: [Role] = [Role]()) {
		self.business = business
		self.employee = employee
		self.allBranches = branches
		self.allRoles = roles
		
		self.businessListener = FirestoreHelper.getBusinessWithListener(businessId: employee.businessId){ business in
            if let business = business{
                self.business = business
				NotificationCenter.default.post(name: Notification.Name("getBusiness"), object: nil)
            }
        }
		
		self.branchListener = FirestoreHelper.getBranches(businessId: employee.businessId){ branches in
            if let branches = branches{
                self.allBranches = branches
				NotificationCenter.default.post(name: Notification.Name("getBranches"), object: nil)
            }
        }

        self.roleListener = FirestoreHelper.getRoles(businessId: employee.businessId){ roles in
            if let roles = roles{
                self.allRoles = roles
				NotificationCenter.default.post(name: Notification.Name("getRoles"), object: nil)
            }
        }
        
        self.employeeListener = FirestoreHelper.getEmployees(businessId: employee.businessId){ employees in
            if let employees = employees{
                self.allEmployees = employees
				NotificationCenter.default.post(name: Notification.Name("getEmployees"), object: nil)
            }
        }
	}
	
	deinit {
		businessListener?.remove()
		branchListener?.remove()
		roleListener?.remove()
        employeeListener?.remove()
	}
	
	func refreshInvoices(completion: ((_ invoices: [Invoice]? )->())? = nil){
		if employee.appRole == .owner {
			CloudFunctionsHelper.getSubscriptionInvoices(){ invoices in
				self.invoices = invoices
				completion?(invoices)
			}
		} else {
			completion?(nil)
		}
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
