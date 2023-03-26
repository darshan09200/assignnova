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
		Color(color: UIColor(hex: "#560319")!, name: "Dark Scarlet"),
        Color(color: UIColor(hex: "#8B0000")!, name: "Red Wine"),
        Color(color: UIColor(hex: "#800000")!, name: "Maroon"),
        Color(color: UIColor(hex: "#C11B17")!, name: "Pepper"),
        Color(color: UIColor(hex: "#B21807")!, name: "Red"),
        Color(color: UIColor(hex: "#E42217")!, name: "Lava Red"),
        Color(color: UIColor(hex: "#F62217")!, name: "Ruby"),
        Color(color: UIColor(hex: "#FF4500")!, name: "Orange Red"),
        Color(color: UIColor(hex: "#FF5F1F")!, name: "Bright Orange"),
        Color(color: UIColor(hex: "#FF7722")!, name: "Saffron"),
        Color(color: UIColor(hex: "#EB5406")!, name: "Red Gold"),
        Color(color: UIColor(hex: "#FFA62F")!, name: "Cantaloupe"),
        Color(color: UIColor(hex: "#5C3317")!, name: "Bakers Brown"),
        Color(color: UIColor(hex: "#7E3817")!, name: "Sangria"),
        Color(color: UIColor(hex: "#804A00")!, name: "Dark Bronze"),
        Color(color: UIColor(hex: "#A97142")!, name: "Metallic Bronze"),
        Color(color: UIColor(hex: "#B87333")!, name: "Copper"),
        Color(color: UIColor(hex: "#A0522D")!, name: "Sienna"),
        Color(color: UIColor(hex: "#EE9A4D")!, name: "Brown Sand"),
        Color(color: UIColor(hex: "#FFFF00")!, name: "Yellow", forAvatar: false),
        Color(color: UIColor(hex: "#FFEF00")!, name: "Canary Yellow", forAvatar: false),
        Color(color: UIColor(hex: "#FFF380")!, name: "Corn Yellow", forAvatar: false),
        Color(color: UIColor(hex: "#FFE87C")!, name: "Sun Yellow", forAvatar: false),
        Color(color: UIColor(hex: "#FDD017")!, name: "Bright Gold"),
        Color(color: UIColor(hex: "#254117")!, name: "Forest"),
        Color(color: UIColor(hex: "#437C17")!, name: "Seaweed"),
        Color(color: UIColor(hex: "#6AA121")!, name: "Green Onion"),
        Color(color: UIColor(hex: "#32CD32")!, name: "Lime Green "),
        Color(color: UIColor(hex: "#9DC209")!, name: "Pistachio Green"),
        Color(color: UIColor(hex: "#BAB86C")!, name: "Olive"),
        Color(color: UIColor(hex: "#B5A642")!, name: "Brass"),
        Color(color: UIColor(hex: "#827839")!, name: "Moccasin"),
        Color(color: UIColor(hex: "#045F5F")!, name: "Medium Teal"),
        Color(color: UIColor(hex: "#2E8B57")!, name: "Sea Green"),
  
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
