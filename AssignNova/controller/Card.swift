//
//  Card.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-21.
//

import UIKit
import SDWebImage

@IBDesignable
class Card: UIView {
	
	var rightIconClosure: (()->())?
	static let identifier = "Card"
	
	@IBOutlet var contentView: UIView!
	
	@IBOutlet weak var barView: UIView!
	@IBOutlet weak var profileAvatarContainer: UIView!
	@IBOutlet weak var profileAvatar: UIImageView!
	
	@IBOutlet weak var titleLabelComponent: UILabel!
	@IBOutlet weak var titleImageView: UIImageView!
	
	@IBOutlet weak var subtitleLabelComponent: UILabel!
	
	@IBOutlet weak var rightImageContainer: UIView!
	@IBOutlet weak var rightImageView: UIImageView!
	
	@IBInspectable
	var title: String? {
		didSet{
			titleLabelComponent.text = title
		}
	}
	
	@IBInspectable
	var subtitle: String? {
		didSet{
			subtitleLabelComponent.text = subtitle
			if subtitle == nil || subtitle!.isEmpty{
				subtitleLabelComponent.isHidden = true
			} else {
				subtitleLabelComponent.isHidden = false
			}
		}
	}
	
	@IBInspectable
	var rightIcon: UIImage?{
		didSet{
			rightImageView.image = rightIcon
			if rightIcon == nil{
				rightImageContainer.isHidden = true
			} else {
				rightImageContainer.isHidden = false
			}
		}
	}
	
	@IBInspectable
	var rightIconColor: UIColor?{
		didSet{
			rightImageView.tintColor = rightIconColor
		}
	}
	
	var urlForProfileImage: String?{
		didSet{
			
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
		
		let bundle = Bundle(for: Card.self)
		bundle.loadNibNamed(Card.identifier, owner: self, options: nil)
		contentView.frame = bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		addSubview(contentView)
		
		profileAvatarContainer.isHidden = true
		titleImageView.isHidden = true
		rightImageContainer.isHidden = true
		subtitleLabelComponent.isHidden = true
	}
	@IBAction func onRightIconPress(_ sender: UITapGestureRecognizer) {
		rightIconClosure?()
	}
	
	func setProfileImage(withName name: String, backgroundColor: String? = nil){
		profileAvatar.image = UIImage.makeLetterAvatar(withName: name, backgroundColor: backgroundColor != nil ? UIColor(hex: backgroundColor!) : nil).0
		profileAvatarContainer.isHidden = false
	}
	
	func setProfileImage(withUrl url: String){
		profileAvatar.sd_imageTransition = .fade
		profileAvatar.sd_setImage(with: URL(string: url))
		profileAvatarContainer.isHidden = false
	}
}
