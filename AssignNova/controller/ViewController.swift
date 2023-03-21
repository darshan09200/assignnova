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
//		self.present(SelectLocationViewController.getController(selectLocationDelegate: self),
//					 animated:true, completion: nil)
        //UIStoryboard(name: "SignInScreen", bundle: nil).instantiateViewController(withIdentifier: "SignIn")
        navigationController?.pushViewController(UIStoryboard(name: "SignInScreen", bundle: nil).instantiateViewController(withIdentifier: "SignInVC"), animated: true)
	}

	@IBAction func onOpenOtpInputPress(_ sender: Any) {
		let viewController = UIStoryboard(name: "Branch", bundle: nil)
			.instantiateViewController(withIdentifier: "AddBranchVC")
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}

	@IBAction func onOpenSignUpBusinessPress(_ sender: Any) {
		let signUpBusinessVC = UIStoryboard(name: "SignUpBusiness", bundle: nil)
			.instantiateViewController(withIdentifier: "SignUpBusinessAccountVC") as! SignUpBusinessAccountVC
		self.navigationController?.pushViewController(signUpBusinessVC, animated: true)
	}

	@IBAction func onOpenSetupBusinessPress(_ sender: Any) {
		let setupBusinessVC = UIStoryboard(name: "SignUpBusiness", bundle: nil)
			.instantiateViewController(withIdentifier: "SetupBusinessVC") as! SetupBusinessVC
		self.navigationController?.pushViewController(setupBusinessVC, animated: true)
	}
}

extension ViewController: SelectLocationDelegate {
	func onSelectLocation(place: GMSPlace) {
		print(place)
	}

	func onCancelLocation() {
		print("cancelled")
	}
}
