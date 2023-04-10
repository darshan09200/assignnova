//
//  Firestore.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-19.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreHelper{
	static let db = Firestore.firestore()
	static func completion(_ error: Error?, _ completion: @escaping(_ error: Error?)->()){
		if let error = error {
			print(error)
			completion(error)
		} else {
			completion(nil)
		}
	}

	static func saveEmployee(_ employee: Employee, completion: @escaping(_ error: Error?)->()) -> DocumentReference?{
		do{
			if let employeeId = employee.id{
				try db.collection("employee").document(employeeId).setData(from: employee){ err in FirestoreHelper.completion(err, completion)
				}
				
				return nil
			} else {
				return try db.collection("employee").addDocument(from: employee){ err in FirestoreHelper.completion(err, completion)
				}
			}
		} catch{
			completion(error)
		}
		return nil
	}

	static func saveBusiness(_ business: Business, completion: @escaping(_ error: Error?)->()) -> DocumentReference?{
		do{
			var reference: DocumentReference?
			reference = try db.collection("business").addDocument(from: business) { err in
				if let error = err{
					print(error)
					completion(error)
					return
				}
				if let businessId = reference?.documentID{
					let branch = Branch(name: business.name, address: business.address, location: business.location, businessId: businessId, color: ColorPickerVC.colors.first!.color.toHex!)
					saveBranch(branch, completion: completion)
				} else {
					completion(nil)
				}
			}
			return reference
		} catch{
			completion(error)
		}
		return nil
	}

	static func saveBranch(_ branch: Branch, completion: @escaping(_ error: Error?)->()){
		do{
			if let branchId = branch.id{
				try db.collection("branch").document(branchId).setData(from: branch){ err in FirestoreHelper.completion(err, completion)
				}
			} else {
				try db.collection("branch").addDocument(from: branch){ err in FirestoreHelper.completion(err, completion)
				}
			}
		} catch{
			completion(error)
		}
	}

	static func saveRole(_ role: Role, completion: @escaping(_ error: Error?)->()){
		do{
			if let roleId = role.id{
				try db.collection("role").document(roleId).setData(from: role){ err in FirestoreHelper.completion(err, completion)
				}
			} else {
				try db.collection("role").addDocument(from: role){ err in FirestoreHelper.completion(err, completion)
				}
			}
		} catch{
			completion(error)
		}
	}

	static func getEmployee(userId: String, completion: @escaping(_ employee: Employee?)->()){
		let docRef = db.collection("employee").whereField("userId", isEqualTo: userId)
			.limit(to: 1)
		docRef.getDocuments(){ snapshots, err in
			if let _ = err {
				completion(nil)
				return
			}
			if let snapshot = snapshots?.documents.first{
				do{
					try completion(snapshot.data(as: Employee.self))
				} catch{
					completion(nil)
				}
			} else{
				completion(nil)
			}
		}
	}
	
	static func getEmployee(employeeId: String, completion: @escaping(_ employee: Employee?)->()) -> ListenerRegistration{
		let docRef = db.collection("employee").document(employeeId)
		return docRef.addSnapshotListener(){ snapshot, err in
			if let _ = err {
				completion(nil)
				return
			}
			do{
				try completion(snapshot?.data(as: Employee.self))
			}catch{
				completion(nil)
			}
		}
	}
	
	static func doesEmployeeExist(email: String, phoneNumber: String?, employeeId: String? = nil, completion: @escaping(_ employee: Employee?)->()){
		if let activeEmployee = ActiveEmployee.instance,
		   let businessId = activeEmployee.business?.id{
			var filters = [
				Filter.whereField("email", isEqualTo: email)
			]
			if let phoneNumber = phoneNumber, !phoneNumber.isEmpty {
				filters.append(Filter.whereField("phoneNumber", isEqualTo: phoneNumber))
			}
			var docRef = db.collection("employee")
				.whereFilter(Filter.orFilter(filters))
			
			if let employeeId = employeeId{
				print("added employeeId \(employeeId)")
				docRef = docRef.whereField("__name__", isNotEqualTo: employeeId)
			}
			
			docRef.limit(to: 1).getDocuments(){ snapshots, err in
				if let _ = err {
					completion(nil)
					return
				}
				if let snapshot = snapshots?.documents.first{
					do{
						try completion(snapshot.data(as: Employee.self))
					} catch{
						completion(nil)
					}
				} else{
					completion(nil)
				}
			}
		} else{
			completion(nil)
		}
	}

	static func getBusiness(businessId: String, completion: @escaping(_ business: Business?)->()){
		if businessId.isEmpty{
			completion(nil)
			return
		}
		let docRef = db.collection("business").document(businessId)
		docRef.getDocument(){ document, err in
			if let _ = err {
				completion(nil)
				return
			}
			do{
				try completion(document?.data(as: Business.self))
			} catch{
				completion(nil)
			}
			
		}
	}

	static func getBranches(businessId: String, completion: @escaping(_ branch: [Branch]?)->()) -> ListenerRegistration{
		let docRef = db.collection("branch")
			.whereField("businessId", isEqualTo: businessId)
			.order(by: "createdAt")
		return docRef.addSnapshotListener(){ snapshots, err in
			if let _ = err {
				completion(nil)
				return
			}
			let branches = snapshots?.documents.compactMap{ document in
				return try? document.data(as: Branch.self)
			}
			completion(branches)
		}
	}

	static func getBranch(branchId: String, completion: @escaping(_ branch: Branch?)->()) -> ListenerRegistration{
		let docRef = db.collection("branch")
			.document(branchId)
		return docRef.addSnapshotListener(){ snapshot, err in
			if let _ = err {
				completion(nil)
				return
			}
			do{
				try completion(snapshot?.data(as: Branch.self))
			}catch{
				completion(nil)
			}
		}
	}

	static func getRoles(businessId: String, completion: @escaping(_ role: [Role]?)->()) -> ListenerRegistration{
		let docRef = db.collection("role")
			.whereField("businessId", isEqualTo: businessId)
			.order(by: "createdAt")
		return docRef.addSnapshotListener(){ snapshots, err in
			if let _ = err {
				completion(nil)
				return
			}
			let roles = snapshots?.documents.compactMap{ document in
				return try? document.data(as: Role.self)
			}
			completion(roles)
		}
	}

	static func getRole(roleId: String, completion: @escaping(_ role: Role?)->()) -> ListenerRegistration{
		let docRef = db.collection("role")
			.document(roleId)
		return docRef.addSnapshotListener(){ snapshot, err in
			if let _ = err {
				completion(nil)
				return
			}
			do{
				try completion(snapshot?.data(as: Role.self))
			}catch{
				completion(nil)
			}
		}
	}
	
	static func getEmployees(businessId: String, branchId: String? = nil, roleId: String? = nil, completion: @escaping(_ employees: [Employee]?)->()) -> ListenerRegistration{
		var docRef = db.collection("employee")
			.whereField("businessId", isEqualTo: businessId)
			.order(by: "firstName")
			.order(by: "lastName")
		if let branchId = branchId{
			docRef = docRef.whereField("branches", arrayContains: branchId)
		}
		if let roleId = roleId{
			docRef = docRef.whereField("roles", arrayContains: roleId)
		}
		return docRef.addSnapshotListener(){ snapshots, err in
			if let _ = err {
				completion(nil)
				return
			}
			let employees = snapshots?.documents.compactMap{ document in
				return try? document.data(as: Employee.self)
			}
			completion(employees)
		}
	}
	
	static func registerFCMToken(){
		if let employeeId = ActiveEmployee.instance?.employee.id, let fcmToken = ActiveEmployee.fcmToken{
			db.collection("employee").document(employeeId).updateData([
				"fcmTokens": FieldValue.arrayUnion([fcmToken])
			])
		}
	}
	
	static func deregisterFCMToken(){
		if let employeeId = ActiveEmployee.instance?.employee.id, let fcmToken = ActiveEmployee.fcmToken{
			db.collection("employee").document(employeeId).updateData([
				"fcmTokens": FieldValue.arrayRemove([fcmToken])
			])
		}
	}
	
	static func saveShifts(_ shifts: [Shift], completion: @escaping(_ error: Error?)->()){
		do{
			let batch = db.batch()
			try shifts.forEach{shift in
				let ref = db.collection("shift").document()
				try ref.setData(from: shift)
			}
			batch.commit(){ err in
				FirestoreHelper.completion(err, completion)
			}
		} catch{
			completion(error)
		}
	}
	
	static func saveShift(_ shift: Shift, completion: @escaping(_ error: Error?)->()) -> DocumentReference?{
		do{
			if let shiftId = shift.id{
				try db.collection("shift").document(shiftId).setData(from: shift){ err in FirestoreHelper.completion(err, completion)
				}
			} else {
				return try db.collection("shift").addDocument(from: shift){ err in FirestoreHelper.completion(err, completion)
				}
			}
		} catch{
			completion(error)
		}
		return nil
	}
	
	static func getShift(shiftId: String, completion: @escaping(_ shift: Shift?)->()) -> ListenerRegistration{
		let docRef = db.collection("shift")
			.document(shiftId)
		return docRef.addSnapshotListener(){ snapshot, err in
			if let _ = err {
				completion(nil)
				return
			}
			do{
				try completion(snapshot?.data(as: Shift.self))
			}catch{
				completion(nil)
			}
		}
	}
	
	static func getShifts(businessId: String, startDate: Date, endDate: Date, shiftType: ShiftType, completion: @escaping(_ shifts: [Shift]?)->()) -> ListenerRegistration{
		var filters = [Filter]()
		if let activeEmployee = ActiveEmployee.instance{
			if shiftType == .myShift{
				filters.append(Filter.whereField("employeeId", isEqualTo: activeEmployee.employee.id!))
			} else if shiftType == .openShift{
				filters.append(Filter.whereField("eligibleEmployees", arrayContains: activeEmployee.employee.id!))
				filters.append(Filter.whereField("eligibleEmployees", isEqualTo: []))
			}
		}
		print(businessId)
		let docRef = db.collection("shift")
			.whereField("businessId", isEqualTo: businessId)
			.whereField("shiftStartDate", isGreaterThanOrEqualTo: startDate.startOfDay)
			.whereField("shiftStartDate", isLessThanOrEqualTo: endDate.endOfDay)
			.whereFilter(Filter.orFilter(filters))
			.order(by: "shiftStartDate")
			.order(by: "shiftStartTime")
		return docRef.addSnapshotListener(){ snapshots, err in
			if let _ = err {
				completion(nil)
				return
			}
			let shifts = snapshots?.documents.compactMap{ document in
				return try? document.data(as: Shift.self)
			}.filter{$0.noOfOpenShifts == nil || $0.noOfOpenShifts! > 0}
			completion(shifts)
		}
	}
	
	static func takeShift(_ shift: Shift, completion: @escaping(_ error: Error?)->()) -> DocumentReference?{
		if let shiftId = shift.id, let employeeId = ActiveEmployee.instance?.employee.id{
			var newShift = shift
			newShift.id = nil
			newShift.updatedAt = nil
			newShift.eligibleEmployees = nil
			newShift.noOfOpenShifts = nil
			newShift.employeeId = employeeId
			if ActionsHelper.hasPrivileges(branchId: shift.branchId){
				newShift.status = .approved
				newShift.acceptedBy = employeeId
			} else {
				newShift.status = .requested
			}
			return saveShift(newShift){ error in
				if let error = error{
					completion(error)
				}
				db.collection("shift").document(shiftId).updateData([
					"noOfOpenShifts": FieldValue.increment(Int64(-1)),
					"eligibleEmployees": FieldValue.arrayRemove([employeeId]),
				], completion: completion)
			}
		}
		return nil
	}
	
	static func deleteShift(_ shiftId: String, completion: @escaping(_ error: Error?)->()){
		db.collection("shift").document(shiftId).delete(){ err in
			FirestoreHelper.completion(err, completion)
		}
	}
	
	static func createTimeOff(_ timeOff: TimeOff, completion: @escaping(_ error: Error?)->()){
		do{
			if let timeOffId = timeOff.id{
				try db.collection("timeOff").document(timeOffId).setData(from: timeOff){ err in FirestoreHelper.completion(err, completion)
				}
			} else {
				try db.collection("timeOff").addDocument(from: timeOff){ err in FirestoreHelper.completion(err, completion)
				}
			}
		} catch{
			completion(error)
		}
	}
	
	static func getTimeOffs(employeeId: String, completion: @escaping(_ timeOffs: [TimeOff]?)->()) -> ListenerRegistration{
		let docRef = db.collection("timeOff")
			.whereField("employeeId", isEqualTo: employeeId)
			.order(by: "createdOn", descending: true)
		return docRef.addSnapshotListener(){ snapshots, err in
			if let _ = err {
				completion(nil)
				return
			}
			let timeOffs = snapshots?.documents.compactMap{ document in
				return try? document.data(as: TimeOff.self)
			}
			completion(timeOffs)
		}
	}

	static func getOpenShifts(employeeId: String, completion: @escaping(_ shifts: [Shift]?)->()) -> ListenerRegistration{
		let docRef = db.collection("shift")
			.whereField("employeeId", isEqualTo: employeeId)
			.whereField("approvalRequired", isEqualTo: true)
			.order(by: "shiftStartDate", descending: true)
			.order(by: "shiftStartTime", descending: true)
		return docRef.addSnapshotListener(){ snapshots, err in
			if let _ = err {
				completion(nil)
				return
			}
			let shifts = snapshots?.documents.compactMap{ document in
				return try? document.data(as: Shift.self)
			}
			completion(shifts)
		}
	}
	
	static func getTimeOff(timeOffId: String, completion: @escaping(_ timeOff: TimeOff?)->()) -> ListenerRegistration{
		let docRef = db.collection("timeOff")
			.document(timeOffId)
		return docRef.addSnapshotListener(){ snapshot, err in
			if let _ = err {
				completion(nil)
				return
			}
			do{
				try completion(snapshot?.data(as: TimeOff.self))
			}catch{
				completion(nil)
			}
		}
	}
	
	static func updateTimeOffStatus(timeOffId: String, status: Status, completion: @escaping(_ error: Error?)->()){
		db.collection("timeOff").document(timeOffId).updateData([
			"status": status.rawValue
		], completion: completion)
	}
	
	static func updateShiftStatus(shiftId: String, status: Status, completion: @escaping(_ error: Error?)->()){
		db.collection("shift").document(shiftId).updateData([
			"status": status.rawValue
		], completion: completion)
	}
	
	static func clockIn(for shift: Shift, completion: @escaping(_ error: Error?)->()){
		var updatedShift = shift
		updatedShift.attendance = Attendance(clockedInAt: .now)
		do{
			try db.collection("shift").document(updatedShift.id!).setData(from: updatedShift){ error in
				FirestoreHelper.completion(error, completion)
			}
		}
		catch{
			completion(error)
		}
	}
	
	static func clockOut(for shift: Shift, completion: @escaping(_ error: Error?)->()){
		var updatedShift = shift
		updatedShift.attendance?.clockedOutAt = .now
		do{
			try db.collection("shift").document(updatedShift.id!).setData(from: updatedShift){ error in
				FirestoreHelper.completion(error, completion)
			}
		}
		catch{
			completion(error)
		}
	}
	
	static func startBreak(for shift: Shift, completion: @escaping(_ error: Error?)->()){
		var updatedShift = shift
		updatedShift.attendance?.breaks.append(Break(start: .now))
		do{
			try db.collection("shift").document(updatedShift.id!).setData(from: updatedShift){ error in
				FirestoreHelper.completion(error, completion)
			}
		}
		catch{
			completion(error)
		}
	}
	
	static func endBreak(for shift: Shift, completion: @escaping(_ error: Error?)->()){
		var updatedShift = shift
		if let index = updatedShift.attendance?.breaks.endIndex{
			updatedShift.attendance?.breaks[index - 1].end = .now
			do{
				try db.collection("shift").document(updatedShift.id!).setData(from: updatedShift){ error in
					FirestoreHelper.completion(error, completion)
				}
			}
			catch{
				completion(error)
			}
		} else {
			completion(FirestoreError.breakNoteStarted)
		}
	}
	
	static func getCurrentWeekStats(completion: @escaping(_ shiftStats: ShiftStats?)->()){
		if let employee = ActiveEmployee.instance?.employee, let employeeId = employee.id{
			let currentDate = Date()
			
			let startOfWeek = currentDate.startOfWeek
			let endOfWeek = currentDate.endOfWeek
			db.collection("shift")
				.whereField("employeeId", isEqualTo: employeeId)
				.whereField("shiftStartDate", isGreaterThanOrEqualTo: startOfWeek)
				.whereField("shiftStartDate", isLessThanOrEqualTo: endOfWeek)
				.order(by: "shiftStartDate")
				.addSnapshotListener(){ snapshots, err in
					if let _ = err {
						completion(nil)
						return
					}
					
					let shifts = snapshots?.documents.compactMap{ document in
						return try? document.data(as: Shift.self)
					} ?? []
					
					var shiftStats = ShiftStats(pendingHours: 0, completedHours: 0)
					
					var pendingHours = 0.0
					var completedHours = 0.0
					
					let dateForUpcomingShift = Calendar.current.date(byAdding: .day, value: 1, to: currentDate.getLast15())!
					for shift in shifts{
						if shift.attendance?.clockedInAt != nil &&  shift.attendance?.clockedOutAt != nil{
							completedHours += Double(Date.getMinutesDifferenceBetween(start: shift.shiftStartTime, end: shift.shiftEndTime)) / 60
						} else {
							pendingHours += Double(Date.getMinutesDifferenceBetween(start: shift.shiftStartTime, end: shift.shiftEndTime)) / 60
						}
						if shiftStats.upcomingShift == nil, shift.shiftStartTime >= currentDate.getLast15() && shift.shiftStartTime <= dateForUpcomingShift && shift.attendance == nil{
							shiftStats.upcomingShift = shift
						}
						if shiftStats.ongoingShift == nil, shift.attendance?.clockedOutAt == nil && shift.attendance?.clockedInAt != nil {
							shiftStats.ongoingShift = shift
						}
					}
					
					shiftStats.pendingHours = pendingHours
					shiftStats.completedHours = completedHours
					completion(shiftStats)
				}
		} else {
			completion(nil)
		}
	}
	
	static func saveAvailability(_ availability: Availability, completion: @escaping(_ error: Error?)->()) {
		do{
			if let availabilityId = availability.id{
				try db.collection("availability").document(availabilityId).setData(from: availability){ err in FirestoreHelper.completion(err, completion)
				}
			} else {
				try db.collection("availability").addDocument(from: availability){ err in FirestoreHelper.completion(err, completion)
				}
			}
		} catch{
			completion(error)
		}
	}
	
	static func getAvailbilities(startDate: Date, endDate: Date, completion: @escaping(_ availabilities: [Availability]?)->()) -> ListenerRegistration{
		let docRef = db.collection("availability")
			.whereField("businessId", isEqualTo: ActiveEmployee.instance!.employee.businessId)
			.whereField("date", isGreaterThanOrEqualTo: startDate.startOfDay)
			.whereField("date", isLessThanOrEqualTo: endDate.endOfDay)
			.whereField("employeeId", isEqualTo: ActiveEmployee.instance!.employee.id!)
			.order(by: "date")
			.order(by: "startTime")
		return docRef.addSnapshotListener(){ snapshots, err in
			if let _ = err {
				completion(nil)
				return
			}
			let availabilities = snapshots?.documents.compactMap{ document in
				return try? document.data(as: Availability.self)
			}
			completion(availabilities)
		}
	}
	
	static func deleteAvailability(_ availabilityId: String, completion: @escaping(_ error: Error?)->()){
		db.collection("availability").document(availabilityId).delete(){ err in
			FirestoreHelper.completion(err, completion)
		}
	}
	
	
}

enum ShiftType{
	case myShift
	case openShift
	case allShift
}

enum FirestoreError: String, Error{
	case breakNoteStarted = "Break Not Started"
}

struct ShiftStats{
	var ongoingShift: Shift?
	var upcomingShift: Shift?
	var pendingHours: Double
	var completedHours: Double
}
