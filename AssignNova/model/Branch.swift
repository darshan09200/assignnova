//
//  Branch.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import GeoFire

struct Branch: Codable{
	@DocumentID var id: String?
	var name: String
	var address: String
	var geohash: String
	var location: GeoPoint
	var businessId: String
	var color: String
	var createdBy: String
	@ServerTimestamp var createdAt: Date?
	@ServerTimestamp var updatedAt: Date?
	
	init(id: String? = nil, name: String, address: String, location: GeoPoint, businessId: String, color: String) {
		self.id = id
		self.name = name
		self.address = address
		self.location = location
		self.businessId = businessId
		self.color = color

		self.geohash = GFUtils.geoHash(forLocation: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
		
		self.createdBy = ActiveEmployee.instance?.employee.id ?? ""
	}
}
