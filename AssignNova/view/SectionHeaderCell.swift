//
//  SectionHeaderCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit

class SectionHeaderCell: UITableViewCell {

	@IBOutlet weak var sectionTitle: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		selectionStyle = .none
    }

}
