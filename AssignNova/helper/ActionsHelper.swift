//
//  ActionsHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-02.
//

import UIKit

class ActionsHelper{
	static func hasPrivileges(branchId: String?) -> Bool{
		guard let employee = ActiveEmployee.instance?.employee else {return false}
		if employee.appRole == .owner || employee.appRole == .manager {return true}
		if let branchId = branchId{
			return employee.branches.contains(branchId)
		}
		return false
	}
	
	static func getAction(for shift: Shift) -> ActionType{
		guard let employee = ActiveEmployee.instance?.employee,
			  let employeeId = employee.id else {return .none}
		
		if let eligibleEmployees = shift.eligibleEmployees,
		   let noOfShifts = shift.noOfOpenShifts, noOfShifts > 0{
			if eligibleEmployees.contains(employeeId) { return .takeShift}
			if eligibleEmployees.count == 0 &&
				(employee.branches.count > 0 ? employee.branches.contains(shift.branchId) : true) &&
				(employee.roles.count > 0 ? employee.roles.contains(shift.roleId) : true) {
				return .takeShift
			}
		} else if shift.approvalRequired && shift.status == .requested, hasPrivileges(branchId: shift.branchId){
			return .approve
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
			} else if (.now.zeroSeconds >= Date.combineDateWithTime(date: shift.shiftStartDate, time: shift.shiftStartTime).zeroSeconds ) && (.now.zeroSeconds < Date.combineDateWithTime(date: shift.shiftStartDate, time: shift.shiftEndTime).zeroSeconds){
				return .clockIn
			}
		}
		
		return .none
	}
}
