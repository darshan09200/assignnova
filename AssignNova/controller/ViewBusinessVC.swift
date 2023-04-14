//
//  ViewBusinessVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-14.
//

import UIKit

class ViewBusinessVC: UIViewController {

	@IBOutlet weak var businessNameLabel: UILabel!
	@IBOutlet weak var businessAddressLabel: UILabel!
	@IBOutlet weak var businessMap: UIImageView!
	@IBOutlet weak var priceCard: PlanCard!
	@IBOutlet weak var priceNotes: UILabel!
	@IBOutlet weak var editBtn: UIBarButtonItem!
	var business: Business?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.editBtn.isHidden = true
		
		if let employee = ActiveEmployee.instance?.employee{
			self.editBtn.isHidden = employee.appRole != .owner
			if employee.appRole == .owner {
				priceCard.isHidden = false
				priceNotes.isHidden = false
			} else {
				priceCard.isHidden = true
				priceNotes.isHidden = true
			}
			let businessId = employee.businessId
			FirestoreHelper.getBusinessWithListener(businessId: businessId){ business in
				self.business = business
				if let business = business{
					self.businessNameLabel.text = business.name
					self.businessAddressLabel.text = business.address
					
					if let apiKey = ProcessInfo.processInfo.environment["MAPS_API_KEY"]{
						var baseUrl = URL(string: "https://maps.googleapis.com/maps/api/staticmap")
						baseUrl?.appendQueryItem(name: "zoom", value: "15")
						baseUrl?.appendQueryItem(name: "size", value: "300x300")
						baseUrl?.appendQueryItem(name: "scale", value: "2")
						baseUrl?.appendQueryItem(name: "markers", value: "label:\(business.name)|\(business.location.latitude), \(business.location.longitude)")
						baseUrl?.appendQueryItem(name: "key", value: apiKey)
						self.businessMap.sd_setImage(with: baseUrl)
					}
					
					self.priceCard.planDetails = "\(business.noOfEmployees) Employees"
					var price = 0.0
					let count = Double(business.noOfEmployees)
					if count < 51 {
						price = count * 4
					} else if count < 251 {
						price = 50 * 4 + (count - 50) * 3.8
					} else {
						price = 50 * 4 + 150 * 3.8 + (count - 150) * 3.6
					}
					self.priceCard.planPrice = "$\(String(format:"%.2f", price))"
				}
			}
		}
    }
    
	@IBAction func onEditPress(_ sender: Any) {
		let viewController = self.storyboard!.instantiateViewController(withIdentifier: "EditBusinessVC") as! EditBusinessVC
		viewController.business = business
		self.present(UINavigationController(rootViewController: viewController), animated: true)
	}
	@IBAction func onMapPress(_ sender: Any) {
		if let business = business {
			UIHelper.openInMap(latitude: business.location.latitude, longitude: business.location.longitude, name: business.name)
		}
	}
}
