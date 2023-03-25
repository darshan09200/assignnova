//
//  BranchCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit

enum CardCellType {
	case none
	case press
	case selection
}

class CardCell: UITableViewCell {

	@IBOutlet weak var card: Card!
	var cardCellType: CardCellType = .press
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		let bgColorView = UIView()
		bgColorView.backgroundColor = .clear
		selectedBackgroundView = bgColorView
		
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		if cardCellType == .press {
			UIView.animate(withDuration: 2, delay: 0, animations: {
				if selected{
					self.card.contentView.backgroundColor = .systemGray5
				} else {
					self.card.contentView.backgroundColor = .systemBackground
				}
			})
		} else if cardCellType == .selection{
			if selected{
				self.card.rightIcon = UIImage(systemName: "checkmark")
			} else {
				self.card.rightIcon = nil
			}
		}
	}

}
