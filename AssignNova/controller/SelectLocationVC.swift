//
//  SelectionLocationViewController.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-17.
//

import UIKit
import GooglePlaces

protocol SelectLocationDelegate{
	func onSelectLocation(place: GMSPlace)
	func onCancelLocation()
}

class SelectLocationVC: UIViewController {

	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	private var tableDataSource: GMSAutocompleteTableDataSource!
	var delegate: SelectLocationDelegate?

	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelPress))
		
		searchBar.delegate = self
		
		tableDataSource = GMSAutocompleteTableDataSource()
		tableDataSource.delegate = self
		
		tableDataSource.tableCellBackgroundColor = .systemBackground
		
		tableView.delegate = tableDataSource
		tableView.dataSource = tableDataSource
	}
	
	@objc func onCancelPress(){
		delegate?.onCancelLocation()
		dismiss(animated: true)
	}
	
	static func getController(delegate: SelectLocationDelegate) -> UINavigationController {
		let selectLocationController = UIStoryboard(name: "SelectLocation", bundle: nil)
			.instantiateViewController(withIdentifier: "SelectLocationVC") as! SelectLocationVC
		
		selectLocationController.delegate = delegate
		
		let navController = UINavigationController(rootViewController: selectLocationController)
		return navController
	}
}

extension SelectLocationVC: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		tableDataSource.sourceTextHasChanged(searchText)
	}
}

extension SelectLocationVC: GMSAutocompleteTableDataSourceDelegate {
	func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
		// Reload table data.
		tableView.reloadData()
	}
	
	func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
		// Reload table data.
		tableView.reloadData()
	}
	
	func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
		delegate?.onSelectLocation(place: place)
		dismiss(animated: true)
	}
	
	func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
		// Handle the error.
		print("Error: \(error.localizedDescription)")
	}
	
	func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
		return true
	}
}
