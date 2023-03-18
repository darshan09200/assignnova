//
//  UIView+CornerRadius.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit

extension UIView{
	@IBInspectable var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
			layer.masksToBounds = newValue > 0
		}
	}
}
