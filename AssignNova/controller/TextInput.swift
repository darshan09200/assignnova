//
//  TextInput.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-17.
//

import UIKit

@IBDesignable
class TextInput: UIView {
	
	static let identifier = "TextInput"

	@IBOutlet var contentView: UIView!
	@IBOutlet weak var labelComponent: UILabel!
	@IBOutlet weak var textFieldComponent: UITextField!
	
	@IBInspectable
	var label: String?{
		didSet{
			self.labelComponent.text = label
		}
	}
	
	@IBInspectable
	var placeholder: String?{
		didSet{
			self.textFieldComponent.placeholder = placeholder
		}
	}
	
	@IBInspectable
	var centerAlignedContent: Bool = false {
		didSet{
			if centerAlignedContent{
				textFieldComponent.textAlignment = .center
			} else {
				textFieldComponent.textAlignment = .natural
			}
		}
	}
	
	@IBInspectable
	var leftIcon: UIImage?{
		didSet{
			if leftIcon != nil {
				textFieldComponent.leftViewMode = .always
				let imageView = UIImageView(frame: CGRect(x: 6, y: 0, width: 30, height: 30))
				imageView.contentMode = .scaleAspectFit
				imageView.image = leftIcon
				let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 30))
				view.addSubview(imageView)
				textFieldComponent.leftView = view
			} else {
				textFieldComponent.leftViewMode = .never
				textFieldComponent.leftView = nil
			}
		}
	}
	
	@IBInspectable
	var leftIconColor: UIColor?{
		didSet{
			textFieldComponent?.leftView?.tintColor = leftIconColor
		}
	}
	
	@IBInspectable
	var rightIcon: UIImage?{
		didSet{
			if rightIcon != nil {
				textFieldComponent.rightViewMode = .always
				let imageView = UIImageView(frame: CGRect(x: 6, y: 0, width: 30, height: 30))
				imageView.contentMode = .scaleAspectFit
				imageView.image = rightIcon
				let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 30))
				view.addSubview(imageView)
				textFieldComponent.rightView = view
			} else {
				textFieldComponent.rightViewMode = .never
				textFieldComponent.rightView = nil
			}
		}
	}
	
	@IBInspectable
	var rightIconColor: UIColor?{
		didSet{
			textFieldComponent?.rightView?.tintColor = rightIconColor
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
		
		let bundle = Bundle(for: TextInput.self)
		bundle.loadNibNamed(TextInput.identifier, owner: self, options: nil)
		contentView.frame = bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		addSubview(contentView)
	}
	
}
