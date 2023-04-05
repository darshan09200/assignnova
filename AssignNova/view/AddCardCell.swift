//
//  AddCardCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit

class AddCardCell: UITableViewCell {

	@IBOutlet weak var addCardButton: UIButton!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		selectionStyle = .none
    }
}
