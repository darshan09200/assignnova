//
//  InputFormCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit

class InputFieldCell: UITableViewCell {

	@IBOutlet var inputField: TextInput!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		selectionStyle = .none
    }

}
