//
//  BranchMapViewController.swift
//  AssignNova
//
//  Created by simran mehra on 2023-03-20.
//

import UIKit
import GoogleMaps
import GeoFire
import FloatingPanel

class BranchMapVC: UIViewController{
	
	let fpc = FloatingPanelController()
	var mapView: GMSMapView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let appearance = SurfaceAppearance()
		appearance.cornerCurve = .continuous
		appearance.cornerRadius = 16.0
		fpc.surfaceView.appearance = appearance
		
		fpc.layout = ListFloatingPanelLayout()
		
		let viewController = storyboard?.instantiateViewController(withIdentifier: "BranchMapListVC") as! BranchMapListVC
		fpc.set(contentViewController: viewController)
		fpc.track(scrollView: viewController.tableView)
		
		fpc.addPanel(toParent: self)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		print(fpc.surfaceView.frame.height)
		print()
		print(UIScreen.main.bounds.height)
		
		let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: view.frame.height - fpc.surfaceLocation.y - view.safeAreaInsets.bottom, right: 0.0)
		mapView?.padding = mapInsets
	}
	
	override func loadView() {
		super.loadView()
		
		let camera = GMSCameraPosition(latitude: 43.7906187, longitude: -79.3544436, zoom: 12)
		mapView = GMSMapView(frame: .zero, camera: camera)
		
		mapView?.isMyLocationEnabled = true
		mapView?.isBuildingsEnabled = false
		
		mapView?.settings.myLocationButton = true
		mapView?.settings.compassButton = true

		mapView?.delegate = self
		self.view = mapView
	}
}
  
extension BranchMapVC: GMSMapViewDelegate{
	func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
		let bottomPosition = view.frame.height - fpc.surfaceLocation.y - view.safeAreaInsets.bottom
		
		let leftCenter = CGPoint(x: 0, y: bottomPosition / 2)
		let rightCenter = CGPoint(x: view.frame.width, y: bottomPosition / 2)
		let topCenter = CGPoint(x: (view.frame.width ) / 2, y: 0)
		let bottomCenter = CGPoint(x: view.frame.width / 2, y: bottomPosition)
		let center = CGPoint(x: view.frame.width / 2, y: bottomPosition / 2)
		
		let leftCenterCoord = mapView.projection.coordinate(for: leftCenter)
		let rightCenterCoord = mapView.projection.coordinate(for: rightCenter)
		let topCenterCoord = mapView.projection.coordinate(for: topCenter)
		let bottomCenterCoord = mapView.projection.coordinate(for: bottomCenter)
		let centerCoord = mapView.projection.coordinate(for: center)
		
		let leftCenterLocation = CLLocation(latitude: leftCenterCoord.latitude, longitude: leftCenterCoord.longitude)
		let rightCenterLocation = CLLocation(latitude: rightCenterCoord.latitude, longitude: rightCenterCoord.longitude)
		let topCenterLocation = CLLocation(latitude: topCenterCoord.latitude, longitude: topCenterCoord.longitude)
		let bottomCenterLocation = CLLocation(latitude: bottomCenterCoord.latitude, longitude: bottomCenterCoord.longitude)
		
		
		let ltrdistance = GFUtils.distance(from: leftCenterLocation, to: rightCenterLocation) / 2
		let ttbdistance = GFUtils.distance(from: topCenterLocation, to: bottomCenterLocation) / 2
		
		let maxDistance = max(ltrdistance, ttbdistance)
		print(GFUtils.queryBounds(forLocation: centerCoord, withRadius: maxDistance))
		
		print(ltrdistance)
		print(ttbdistance)
	}
}

class ListFloatingPanelLayout: FloatingPanelLayout {
	let position: FloatingPanelPosition = .bottom
	let initialState: FloatingPanelState = .half
	let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
		.full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
		.half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
//		.tip: FloatingPanelLayoutAnchor(fractionalInset: 0.25, edge: .bottom, referenceGuide: .safeArea),
	]
}
