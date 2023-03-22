//
//  BranchCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit

class CardCell: UITableViewCell {

	@IBOutlet weak var card: Card!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		let bgColorView = UIView()
		bgColorView.backgroundColor = .clear
		selectedBackgroundView = bgColorView
		
    }

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		UIView.animate(withDuration: 2, delay: 0, animations: {}){_ in
			if selected{
				self.card.contentView.backgroundColor = .systemGray5
			} else {
				self.card.contentView.backgroundColor = .systemBackground
			}
		}
	}
}
