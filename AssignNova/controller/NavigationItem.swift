//
//  NavigationItem.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit

@IBDesignable
class NavigationItem: UIView {
	static let identifier = "NavigationItem"
	
	@IBOutlet var contentView: UIView!
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var labelComponent: UILabel!
	
	@IBInspectable
	var label: String?{
		didSet{
			labelComponent.text = label
		}
	}
	
	@IBInspectable
	var icon: UIImage?{
		didSet{
			imageView.image = icon
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
		
		let bundle = Bundle(for: NavigationItem.self)
		bundle.loadNibNamed(NavigationItem.identifier, owner: self, options: nil)
		contentView.frame = bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		addSubview(contentView)
	}
}
