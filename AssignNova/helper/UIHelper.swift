//
//  ViewHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-18.
//

import UIKit

class UIHelper{
	static func getTopConstraintToMakeBottom(contentView: UIView, view: UIView, topContentHeight: CGFloat, padding: CGFloat = 16, navbarHeight: CGFloat? = 0)-> CGFloat{
		let window = UIApplication.shared.windows.first
		let topPadding = window?.safeAreaInsets.top ?? 0
		let bottomPadding = window?.safeAreaInsets.bottom ?? 0
		
		let mainViewHeight =  UIScreen.main.bounds.height - (navbarHeight ?? 0) - topPadding - bottomPadding
		
		if mainViewHeight > contentView.frame.height{
			return mainViewHeight - topContentHeight - (padding * 2) - view.frame.height
		}
		return padding
	}
}
