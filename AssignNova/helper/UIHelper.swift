//
//  ViewHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit
import CoreLocation
import MapKit

class UIHelper{
	static func getTopConstraintToMakeBottom(contentView: UIView, view: UIView, topContentHeight: CGFloat, padding: CGFloat = 16, navbarHeight: CGFloat? = 0)-> CGFloat{
		let window = UIApplication.shared.windows.first
		let topPadding = window?.safeAreaInsets.top ?? 0
		let bottomPadding = window?.safeAreaInsets.bottom ?? 0
		
		let mainViewHeight =  UIScreen.main.bounds.height - (navbarHeight ?? 0) - topPadding - bottomPadding
		
		if mainViewHeight > contentView.frame.height{
			return mainViewHeight - topContentHeight - (padding * 2) - view.frame.height
		}
		return padding
	}
	
	static func openInMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String){
		let regionDistance:CLLocationDistance = 10000
		let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
		let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
		let options = [
			MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
			MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
		]
		let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
		let mapItem = MKMapItem(placemark: placemark)
		mapItem.name = name
		mapItem.openInMaps(launchOptions: options)
		
		print("called")
	}
	
}
