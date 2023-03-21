//
//  Firestore.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-19.
//

import UIKit
import FirebaseFirestore

class FirestoreHelper{
	static let db = Firestore.firestore()
	
	static func completion(_ error: Error?, _ completion: @escaping(_ error: Error?)->()){
		if let error = error {
			completion(error)
		} else {
			completion(nil)
		}
	}
	
	static func saveUser(_ user: User, completion: @escaping(_ error: Error?)->()){
		do{
			try db.collection("users").document(user.id!).setData(from: user){ err in FirestoreHelper.completion(err, completion)
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
	
	static func getUser(completion: @escaping(_ user: User?)->()){
		if let userId = AuthHelper.userId{
			let docRef = db.collection("users").document(userId)
			docRef.getDocument(as: User.self){ result in
				switch result {
					case .success(let user):
						completion(user)
					default:
						completion(nil)
				}
			}
		} else{
			completion(nil)
		}
	}
	
	static func getBusiness(completion: @escaping(_ business: Business?)->()){
		if let userId = AuthHelper.userId{
			let docRef = db.collection("business").whereField("managedBy", isEqualTo: userId)
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
		} else{
			completion(nil)
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
	
}
