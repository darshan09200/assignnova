//
//  EmployeeDetailsCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-26.
//

import UIKit

class EmployeeDetailsCell: UITableViewCell {

	@IBOutlet weak var empIdLabel: UILabel!
	@IBOutlet weak var empIdPrivatePipe: UILabel!
	@IBOutlet weak var privateLabel: UILabel!
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var appRoleLabel: UILabel!
	
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var emailPhoneNumberPipe: UILabel!
	@IBOutlet weak var phoneNumberLabel: UILabel!
	
	@IBOutlet weak var maxHoursLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		selectionStyle = .none
    }

}
