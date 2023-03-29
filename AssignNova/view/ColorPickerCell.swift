//
//  ColorPickerCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-27.
//

import UIKit

class ColorPickerCell: UITableViewCell {

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var colorView: UIStackView!
	@IBOutlet weak var colorImage: UIImageView!
	@IBOutlet weak var colorLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		selectionStyle = .none
    }

}
