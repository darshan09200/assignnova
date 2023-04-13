//
//  ActionsHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-02.
//

import UIKit
import FirebaseStorage

class ActionsHelper{
	static func hasPrivileges(branchId: String?) -> Bool{
		guard let employee = ActiveEmployee.instance?.employee, employee.appRole != .employee else {return false}
		if employee.appRole == .owner || employee.appRole == .manager {return true}
		if let branchId = branchId {
			return employee.branches.contains(branchId)
		}
		return false
	}
	
	static func hasPrivileges(branchIds: [String]) -> Bool{
		return branchIds.compactMap{hasPrivileges(branchId:$0)}.reduce(true){result, acc in result || acc}
	}
	
	static func canTake(shift: Shift)->Bool{
		guard let employee = ActiveEmployee.instance?.employee,
			  let employeeId = employee.id else {return false}
		if let eligibleEmployees = shift.eligibleEmployees,
		   let noOfShifts = shift.noOfOpenShifts, noOfShifts > 0{
			if eligibleEmployees.contains(employeeId) { return true}
			if eligibleEmployees.count == 0 &&
				(employee.branches.count > 0 ? employee.branches.contains(shift.branchId) : true) &&
				(employee.roles.count > 0 ? employee.roles.contains(shift.roleId) : true) {
				return true
			}
		}
		return false
	}
	
	static func getAction(for shift: Shift) -> ActionType{
		guard let employee = ActiveEmployee.instance?.employee,
			  let employeeId = employee.id else {return .none}
		if shift.employeeId == nil && shift.shiftStartTime <= .now.zeroSeconds { return .expired}
		if canTake(shift: shift) {
			return .takeShift
		} else if shift.approvalRequired && shift.status == .requested{
			if canEdit(){
				return .approve
			} else {
				return .requested
			}
		} else if shift.approvalRequired && shift.status == .declined{
			return .declined
		} else if employeeId == shift.employeeId && (shift.approvalRequired ? shift.status == .approved : true){
			if let attendance = shift.attendance {
				let breaks = attendance.breaks
				if attendance.clockedOutAt == nil{
					if breaks.count == 0 || breaks.last?.end != nil{
						return .clockOut
					} else if breaks.count > 0 && breaks.last?.end == nil{
						return .endBreak
					}
				} else {
					return .completed
				}
			} else if (.now.zeroSeconds >= Date.combineDateWithTime(date: shift.shiftStartDate, time: shift.shiftStartTime).zeroSeconds.add(minute: -5) ) && (.now.zeroSeconds < Date.combineDateWithTime(date: shift.shiftStartDate, time: shift.shiftEndTime).zeroSeconds){
				return .clockIn
			}
		}
		
		return .none
	}
	
	static func getProfileImage(profileUrl: String) -> StorageReference{
		var filename = (profileUrl as NSString).lastPathComponent.split(separator: ".")
		filename.popLast()
		let reducedProfileUrl = "profileImages/\(filename.first ?? "")_200x200.jpeg"		
		return Storage.storage().reference().child(reducedProfileUrl)
	}
	
	static func isTrialActive() -> Bool{
		 guard let subscriptionDetail = ActiveEmployee.instance?.subscriptionDetail, let _ = subscriptionDetail.paymentMethod, subscriptionDetail.canceledAt == nil else {
			 return false
		 }
		 return true
	}
	
	static func isSelf(employee: Employee?)->Bool{
		guard let currentEmployee = ActiveEmployee.instance?.employee,
				let employee = employee else {return false}
		return currentEmployee.id == employee.id
	}
	
	static func canEdit() -> Bool{
		if isTrialActive(){
			guard let employee = ActiveEmployee.instance?.employee else {return false}
			if employee.appRole == .owner || employee.appRole == .manager {return true}
		}
		return false
	}
	
	static func canEdit(shift: Shift) -> Bool{
		if canEdit() && shift.shiftStartTime > .now.zeroSeconds{
			return true
		}
		return false
	}
	
	static func canEdit(role: Role) -> Bool{
		return canEdit()
	}
	
	static func canEdit(employee: Employee?) -> Bool{
		if canEdit(),
			let employee = employee,
			let currentEmployee = ActiveEmployee.instance?.employee {
			return currentEmployee.appRole.index > employee.appRole.index || currentEmployee.appRole == .owner
		}
		return false
	}
	
	static func canEdit(branch : Branch) -> Bool{
		if canEdit(){
			return hasPrivileges(branchId: branch.id)
		}
		return false
	}
	
	static func canAdd() -> Bool{
		return canEdit()
	}
}
