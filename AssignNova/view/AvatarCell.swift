//
//  AvatarCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit

class AvatarCell: UITableViewCell {

	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var addImageButton: UIButton!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		selectionStyle = .none
    }

}
