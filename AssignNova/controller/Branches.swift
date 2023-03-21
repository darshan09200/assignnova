//
//  Branches.swift
//  AssignNova
//
//  Created by simran mehra on 2023-03-20.
//

import Foundation
import MapKit
class Branches {
    var name: String
    var address: String
    var location: CLLocation
    
    init(name: String, address: String, location: CLLocation) {
        self.name = name
        self.address = address
        self.location = location
    }
}
