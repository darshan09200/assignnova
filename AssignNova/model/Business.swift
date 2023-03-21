//
//  Business.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import GeoFire
import FirebaseAuth

struct Business: Codable{
	@DocumentID var id: String?
	var name: String
	var address: String
	var noOfEmployees: Int
	var geohash: String
	var location: GeoPoint
	var managedBy: String
	var subscriptionId: String?
	@ServerTimestamp var createdAt: Date?
	@ServerTimestamp var updatedAt: Date?
	
	init(id: String? = nil, name: String, address: String, noOfEmployees: Int, location: GeoPoint, subscriptionId: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
		self.id = id
		self.name = name
		self.address = address
		self.noOfEmployees = noOfEmployees
		self.location = location
		self.subscriptionId = subscriptionId
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		
		self.geohash = GFUtils.geoHash(forLocation: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
		
		self.managedBy = Auth.auth().currentUser?.uid ?? ""
	}
}
