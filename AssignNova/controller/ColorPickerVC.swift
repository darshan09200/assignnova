//
//  ColorPickerVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-20.
//

import UIKit


protocol ColorPickerDelegate{
	func onSelectColor(color: Color)
	func onCancelColorPicker()
}

class ColorPickerVC: UIViewController {
	
	var delegate: ColorPickerDelegate?
	
	@IBOutlet weak var tableView: UITableView!
	static let colors = [
		Color(color: .systemGray, name: "Default"),
		Color(color: .systemRed, name: "Red"),
		Color(color: .systemBrown, name: "Brown"),
		Color(color: .systemOrange, name: "Orange"),
		Color(color: .systemPink, name: "Pink"),
		Color(color: .systemYellow, name: "Yellow"),
		Color(color: .systemGreen, name: "Green"),
		Color(color: .systemPurple, name: "Purple"),
	]
	
	var selectedColor: UIColor? = colors.first?.color

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		if let selectedColor = selectedColor,
		   let arrayIndex = ColorPickerVC.colors.firstIndex(where: {$0.color.toHex == selectedColor.toHex}){
			let index = ColorPickerVC.colors.distance(from: ColorPickerVC.colors.startIndex, to: arrayIndex)
			tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
		}
    }
	
	static func getController(delegate: ColorPickerDelegate, selectedColor: UIColor?) -> UINavigationController {
		let colorPickerController = UIStoryboard(name: "ColorPicker", bundle: nil)
			.instantiateViewController(withIdentifier: "ColorPickerVC") as! ColorPickerVC
		
		colorPickerController.delegate = delegate
		colorPickerController.selectedColor = selectedColor
		
		let navController = UINavigationController(rootViewController: colorPickerController)
		return navController
	}

	@IBAction func onCancelPress(_ sender: Any) {
		delegate?.onCancelColorPicker()
		dismiss(animated: true)
	}
}

extension ColorPickerVC: UITableViewDelegate, UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return ColorPickerVC.colors.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
		let item = ColorPickerVC.colors[indexPath.row]
		var configuration = cell.defaultContentConfiguration()
		configuration.image = UIImage(systemName: "circle.fill")
		configuration.imageProperties.tintColor = item.color
		configuration.text = item.name
		cell.contentConfiguration = configuration
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		
		guard let cell = tableView.cellForRow(at: indexPath) else { return }
		cell.accessoryType = .checkmark
		
		let item = ColorPickerVC.colors[indexPath.row]
		delegate?.onSelectColor(color: item)
		
		dismiss(animated: true)
	}
}
