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
	
	static func saveUser(_ user: User, completion: @escaping(_ error: Error?)->()){
		do{
			try db.collection("users").document(user.id!).setData(from: user) { err in
				if let err = err {
					completion(err)
				} else {
					completion(nil)
				}
			}
		} catch{
			completion(error)
		}
	}
	
	static func saveBusiness(_ business: Business, completion: @escaping(_ error: Error?)->()){
		do{
			try db.collection("business").addDocument(from: business) { err in
				if let err = err {
					completion(err)
				} else {
					completion(nil)
				}
			}
		} catch{
			completion(error)
		}
	}
}
