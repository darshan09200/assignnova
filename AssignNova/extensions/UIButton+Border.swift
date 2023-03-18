//
//  UIButton+Border.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit

extension UIButton {
	@IBInspectable var borderWidth: CGFloat {
		get {
			return layer.borderWidth
		}
		set {
			layer.borderWidth = newValue
			layer.masksToBounds = newValue > 0
		}
	}
	
	@IBInspectable var borderColor: UIColor {
		get {
			return UIColor.init(cgColor: layer.borderColor!)
		}
		set {
			layer.borderColor = newValue.cgColor
			layoutIfNeeded()
		}
	}
	
}
