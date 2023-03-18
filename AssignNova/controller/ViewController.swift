//
//  ViewController.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-17.
//

import UIKit
import GoogleMaps
import GooglePlaces
import AEOTPTextField
import FirebaseAuth

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
//		let camera = GMSCameraPosition(latitude: 1.285, longitude: 103.848, zoom: 12)
//		let mapView = GMSMapView(frame: .zero, camera: camera)
//		self.view = mapView
		
	}

	@IBAction func onTestButtonPress(_ sender: Any) {
		self.present(SelectLocationViewController.getController(selectLocationDelegate: self),
					 animated:true, completion: nil)
//        navigationController?.pushViewController(UIStoryboard(name: "SignUpEmployee", bundle: nil).instantiateViewController(withIdentifier: "SignUpEmployee"), animated: true)
	}
	
	@IBAction func onOpenOtpInputPress(_ sender: Any) {
		let phoneNumber = "+12345678901"
//		AuthHelper.sendOtp(phoneNumber: phoneNumber){ error in
//			if let error = error{
//				print(error.localizedDescription)
//				return
//			}
			let otpInputController = UIStoryboard(name: "OtpInput", bundle: nil)
				.instantiateViewController(withIdentifier: "OtpInputViewController") as! OtpInputViewController
			UserDefaults.standard.set(phoneNumber, forKey: "authPhoneNumber")
			self.navigationController?.pushViewController(otpInputController, animated: true)
//		}
	}
	
}

extension ViewController: SelectLocationDelegate {
	func onSelectLocation(place: GMSPlace) {
		print(place)
	}
	
	func onCancel() {
		print("cancelled")
	}
}
