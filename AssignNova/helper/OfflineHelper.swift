//
//  OfflineHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-14.
//

import UIKit
import Connectivity

class OfflineHelper{
	
	static var instance = OfflineHelper()
	
	let connectivity = Connectivity(configuration: .init().configurePolling(interval: 5))
	
	init() {
		connectivity.startNotifier()
	}
	
	deinit {
		print("called deinit")
		connectivity.stopNotifier()
	}
	
}
