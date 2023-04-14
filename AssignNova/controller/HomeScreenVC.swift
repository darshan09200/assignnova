//
//  HomeScreenViewController.swift
//  AssignNova
//
//  Created by simran mehra on 2023-04-03.
//

import UIKit
import CoreLocation

class HomeScreenVC:  UIViewController {
	
	@IBOutlet weak var helloLabel: UILabel!
	
	@IBOutlet weak var letsGetStartedLabel: UILabel!
	@IBOutlet weak var paymentButton: NavigationItem!
	@IBOutlet weak var branchButton: NavigationItem!
	@IBOutlet weak var roleButton: NavigationItem!
	@IBOutlet weak var employeeButton: NavigationItem!
	
	@IBOutlet weak var shiftTravelLabel: UIButton!
	
	@IBOutlet weak var completedHoursLabel: UILabel!
	@IBOutlet weak var pendingHoursLabel: UILabel!
	
	@IBOutlet weak var doYouKnowStack: UIStackView!
	@IBOutlet weak var doYouKnow: UILabel!
	
	@IBOutlet weak var shiftLabel: UILabel!
	@IBOutlet weak var shiftCard: Card!
	@IBOutlet weak var noRecordLabel: UILabel!
	
	var shiftStats: ShiftStats?


	override func viewDidLoad() {
		super.viewDidLoad()
		
		let nc = NotificationCenter.default
		let selector = #selector(onDataUpdated)
		nc.addObserver(self, selector: selector, name: Notification.Name("getSubscriptionDetails"), object: nil)
		nc.addObserver(self, selector: selector, name: Notification.Name("getBranches"), object: nil)
		nc.addObserver(self, selector: selector, name: Notification.Name("getRoles"), object: nil)
		nc.addObserver(self, selector: selector, name: Notification.Name("getEmployees"), object: nil)
		
		FirestoreHelper.getCurrentWeekStats(){ shiftStats in
			self.shiftStats = shiftStats
			self.refreshUI()
			
		}
		
		let gesture = UITapGestureRecognizer(target: self, action: #selector(onShiftPress(_ :)))
		shiftCard.addGestureRecognizer(gesture)
		
		
		let greeting = {
			let hour = Calendar.current.component(.hour, from: Date())
			switch hour {
				case 4..<12 : return "Morning"
				case 12..<18 : return "Afternoon"
				default: return "Evening"
			}
		}()
		
		if let employee = ActiveEmployee.instance?.employee{
			helloLabel.text = "Good \(greeting), \(employee.firstName)"
		}

	}
	
	@IBAction func onOpenInMaps(_ sender: Any) {
		if let branchId = shiftStats?.upcomingShift?.branchId,
		let branch = ActiveEmployee.instance?.getBranch(branchId: branchId){
			UIHelper.openInMap(latitude: branch.location.latitude, longitude: branch.location.longitude, name: branch.name)
		}
	}
	
	func refreshUI(){
		letsGetStartedLabel.isHidden = true
		paymentButton.isHidden = true
		branchButton.isHidden = true
		roleButton.isHidden = true
		employeeButton.isHidden = true
		doYouKnowStack.isHidden = true
		
		if let activeEmployee = ActiveEmployee.instance{
			if !activeEmployee.isFetchingSubscription && ( activeEmployee.subscriptionDetail == nil || activeEmployee.subscriptionDetail?.paymentMethod == nil){
				paymentButton.isHidden = false
				letsGetStartedLabel.isHidden = false
			}
			if ActionsHelper.canAdd(){
				if activeEmployee.branches.count == 0 {
					branchButton.isHidden = false
					letsGetStartedLabel.isHidden = false
				}
				
				if activeEmployee.roles.count == 0{
					roleButton.isHidden = false
					letsGetStartedLabel.isHidden = false
				}
				
				if activeEmployee.employees.count <= 1{
					employeeButton.isHidden = false
					letsGetStartedLabel.isHidden = false
				}
			}
			
			if let factOfTheDay = activeEmployee.factOfTheDay{
				doYouKnow.text = factOfTheDay
				doYouKnowStack.isHidden = false
			}
		}
		
		if let shiftStats = shiftStats{
			completedHoursLabel.text = "\(String(format:"%.2f",shiftStats.completedHours)) hrs"
			pendingHoursLabel.text = "\(String(format:"%.2f",shiftStats.pendingHours)) hrs"
			
			var shift: Shift?
			shiftTravelLabel.isHidden = true
			if let ongoingShift = shiftStats.ongoingShift{
				shift = ongoingShift
				shiftLabel.text = "Ongoing Shift"
			} else if let upcomingShift = shiftStats.upcomingShift{
				shift = upcomingShift
				shiftLabel.text = "Next Shift"
				shiftTravelLabel.isHidden = false
			}
			
			if let shift = shift{
				shiftCard.title = Date.buildTimeRangeString(startDate: shift.shiftStartTime, endDate: shift.shiftEndTime)
				let employeeId = shift.employeeId!
				let employee = ActiveEmployee.instance?.getEmployee(employeeId: employeeId)
				var employeeName = "Open Shift"
				if let employee = employee{
					employeeName = employee.name
					if let profileUrl = employee.profileUrl{
						let (image, _) = UIImage.makeLetterAvatar(withName: employee.name , backgroundColor: UIColor(hex: employee.color))
						shiftCard.setProfileImage(withUrl: profileUrl, placeholderImage: image)
					} else {
						shiftCard.setProfileImage(withName: employee.name, backgroundColor: employee.color)
					}
				}
				
				var roleName: String = ""
				if let role = ActiveEmployee.instance?.getRole(roleId: shift.roleId){
					roleName = "as \(role.name)"
				}
				shiftCard.subtitle = "\(employeeName) \(roleName)"
				noRecordLabel.isHidden = true
				shiftCard.isHidden = false
			} else {
				shiftLabel.text = "Next Shift"
				noRecordLabel.isHidden = false
				shiftCard.isHidden = true
			}
		}
	}
	
	@objc func onShiftPress(_ sender: UITapGestureRecognizer){
		if let shift = shiftStats?.ongoingShift ?? shiftStats?.upcomingShift{
			let viewController = UIStoryboard(name: "Shift", bundle: nil).instantiateViewController(withIdentifier: "ViewShiftVC") as! ViewShiftVC
			viewController.shiftId = shift.id
			self.navigationController?.pushViewController(viewController, animated: true)
		} else {
			print("no shift")
		}
	}
	
	@objc func onDataUpdated(){
		refreshUI()
	}
	
	@IBAction func onAuthorizePayment(_ sender: Any) {
		let viewController = UIStoryboard(name: "Payment", bundle: nil)
			.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBAction func addBranchBtn(_ sender: Any) {
		let controller = UIStoryboard(name: "Branch", bundle: nil).instantiateViewController(withIdentifier: "AddBranchVC")
		self.present(UINavigationController(rootViewController: controller), animated: true)
	}
	
	@IBAction func addRoleBtn(_ sender: Any) {
		let controller = UIStoryboard(name: "Role", bundle: nil).instantiateViewController(withIdentifier: "AddRoleVC")
		self.present(UINavigationController(rootViewController: controller), animated: true)
	}
	
	@IBAction func addEmployeeBtn(_ sender: Any) {
		let controller = UIStoryboard(name: "Employee", bundle: nil).instantiateViewController(withIdentifier: "AddEmployeeTVC")
		self.present(UINavigationController(rootViewController: controller), animated: true)
	}
}

//extension HomeScreenVC: CLLocationManagerDelegate{
//	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//		if(manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse) {
//			self.currentLocation = manager.location
//
//			print(currentLocation)
//			getStats()
//		}
//	}
//
//	func getStats(){
//		if let branchId = shiftStats?.upcomingShift?.branchId,
//		   let branch = ActiveEmployee.instance?.getBranch(branchId: branchId),
//		   let currentLocation = currentLocation {
//			let source = currentLocation.coordinate
//			CloudFunctionsHelper.getTravelTime(source: source, dest: CLLocationCoordinate2D(latitude: branch.location.latitude, longitude: branch.location.longitude))
//		}
//	}
//}
