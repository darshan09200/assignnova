//
//  ShiftDetailsCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-26.
//

import UIKit

class ShiftDetailsCell: UITableViewCell {

	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var shiftTime: UILabel!
	
	@IBOutlet weak var unpaidBreak: UILabel!
	
	@IBOutlet weak var noteHeadingLabel: UILabel!
	@IBOutlet weak var noteLabel: UILabel!
	
	@IBOutlet weak var clockedInLabel: UILabel!
	@IBOutlet weak var clockedOutLabel: UILabel!
	@IBOutlet weak var breakTimeLabel: UILabel!
	
	@IBOutlet weak var offerNoteHeadingLabel: UILabel!
	@IBOutlet weak var offerNoteLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		selectionStyle = .none
    }

}
