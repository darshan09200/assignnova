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
	
	var isConnected: Bool{
		switch connectivity.status{
			case .connected: fallthrough
			case .connectedViaCellular: fallthrough
			case .connectedViaEthernet: fallthrough
			case .connectedViaWiFi:
				return true
			case .connectedViaEthernetWithoutInternet: fallthrough
			case .connectedViaCellularWithoutInternet: fallthrough
			case .connectedViaWiFiWithoutInternet: fallthrough
			case .determining: fallthrough
			case .notConnected:			
				return false
		}
	}
	
	init() {
		connectivity.startNotifier()
	}
	
	deinit {
		print("called deinit")
		connectivity.stopNotifier()
	}
	
}
