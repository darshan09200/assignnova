//
//  ViewController.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-17.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController, SelectLocationDelegate {
	func onSelectLocation(place: GMSPlace) {
		print(place)
	}
	
	func onCancel() {
		print("cancelled")
	}
	

	@IBOutlet weak var testButton: UIButton!
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
//		let camera = GMSCameraPosition(latitude: 1.285, longitude: 103.848, zoom: 12)
//		let mapView = GMSMapView(frame: .zero, camera: camera)
//		self.view = mapView
	}

	@IBAction func onTestButtonPress(_ sender: Any) {
        navigationController?.pushViewController(UIStoryboard(name: "ViewEmployee", bundle: nil).instantiateViewController(withIdentifier: "ViewEmployee"), animated: true)
//		self.present(SelectLocationViewController.getController(selectLocationDelegate: self),
//					 animated:true, completion: nil)
	}
	
}

