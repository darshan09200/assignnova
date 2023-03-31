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
			completion(error)
		} else {
			completion(nil)
		}
	}

	static func saveEmployee(_ employee: Employee, completion: @escaping(_ error: Error?)->()){
		do{
			if let employeeId = employee.id{
				try db.collection("employee").document(employeeId).setData(from: employee){ err in FirestoreHelper.completion(err, completion)
				}
			} else {
				try db.collection("employee").addDocument(from: employee){ err in FirestoreHelper.completion(err, completion)
				}
			}
		} catch{
			completion(error)
		}
	}

	static func saveBusiness(_ business: Business, completion: @escaping(_ error: Error?)->()){
		do{
			try db.collection("business").addDocument(from: business) { err in FirestoreHelper.completion(err, completion)
			}
		} catch{
			completion(error)
		}
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
			if let phoneNumber = phoneNumber {
				filters.append(Filter.whereField("phoneNumber", isEqualTo: phoneNumber))
			}
			var docRef = db.collection("employee")
				.whereFilter(Filter.orFilter(filters))
				.whereField("businessId", isEqualTo: businessId)
			
			if let employeeId = employeeId{
				print("added employeeId \(employeeId)")
				docRef = docRef.whereField("__name__", isNotEqualTo: employeeId)
			}
			
			docRef.limit(to: 1)
			
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
		} else{
			completion(nil)
		}
	}

	static func getBusiness(employeeId: String, completion: @escaping(_ business: Business?)->()){
		
		let docRef = db.collection("business").whereField("managedBy", isEqualTo: employeeId)
		docRef.getDocuments(){ snapshots, err in
			if let _ = err {
				completion(nil)
				return
			}
			if let snapshot = snapshots?.documents.first{
				do{
					try completion(snapshot.data(as: Business.self))
				} catch{
					completion(nil)
				}
			} else{
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
	
	static func getEmployees(businessId: String, completion: @escaping(_ employees: [Employee]?)->()) -> ListenerRegistration{
		let docRef = db.collection("employee")
			.whereField("businessId", isEqualTo: businessId)
			.order(by: "firstName")
			.order(by: "lastName")
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
			newShift.status = .requested
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
			.order(by: "createdOn")
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
			.order(by: "shiftStartDate")
			.order(by: "shiftStartTime")
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
}

enum ShiftType{
	case myShift
	case openShift
	case allShift
}
