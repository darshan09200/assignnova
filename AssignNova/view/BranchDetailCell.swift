//
//  BranchDetailCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit

class BranchDetailCell: UITableViewCell {

	
	@IBOutlet weak var branchName: UILabel!
	@IBOutlet weak var branchColor: UIImageView!
	
	@IBOutlet weak var branchAddress: UILabel!
	
	@IBOutlet weak var branchMapImage: UIImageView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
