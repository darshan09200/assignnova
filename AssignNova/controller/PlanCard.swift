//
//  PlanCard.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit

@IBDesignable
class PlanCard: UIView {

	static let identifier = "PlanCard"
	@IBOutlet var contentView: UIView!
	
	@IBOutlet weak var planNameLabel: UILabel!
	@IBOutlet weak var planDetailsLabel: UILabel!
	@IBOutlet weak var planPriceLabel: UILabel!
	
	@IBInspectable
	var planName: String?{
		didSet{
			self.planNameLabel.text = planName
		}
	}
	
	@IBInspectable
	var planDetails: String?{
		didSet{
			self.planDetailsLabel.text = planDetails
			if planDetails == nil || planDetails!.isEmpty{
				planDetailsLabel.isHidden = true
			} else {
				planDetailsLabel.isHidden = false
			}
		}
	}
	
	@IBInspectable
	var planPrice: String?{
		didSet{
			self.planPriceLabel.text = planPrice
		}
	}
	
	@IBInspectable
	var isSelected: Bool = false{
		didSet{
			if isSelected{
				contentView.backgroundColor = .systemBlue
				
				planNameLabel.textColor = .white
				planDetailsLabel.textColor = .white
			} else {
				contentView.backgroundColor = .secondarySystemBackground
				
				planNameLabel.textColor = .label
				planDetailsLabel.textColor = .label
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initSubviews()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initSubviews()
	}
	
	func initSubviews() {
		
		let bundle = Bundle(for: PlanCard.self)
		bundle.loadNibNamed(PlanCard.identifier, owner: self, options: nil)
		contentView.frame = bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		addSubview(contentView)
		
		planDetailsLabel.isHidden = true
	}

}
