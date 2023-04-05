//
//  DayCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-26.
//

import UIKit
import FSCalendar

class DayCell: FSCalendarCell {
	weak var selectionLayer: CAShapeLayer!
	
	required init!(coder aDecoder: NSCoder!) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let selectionLayer = CAShapeLayer()
		selectionLayer.fillColor = UIColor(named: "AccentColor")!.cgColor
		selectionLayer.actions = ["hidden": NSNull()]
		self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
		self.selectionLayer = selectionLayer
		
		self.shapeLayer.isHidden = true
		let view = UIView(frame: self.bounds)
		view.backgroundColor = .clear
		self.backgroundView = view;
		
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)
		self.selectionLayer.frame = self.contentView.bounds
		let side = self.bounds.height
		
		let origin = CGPoint(x: (self.bounds.width - side) / 2, y: 0)
		let size = CGSize(width: side, height: side)
		
		let path = UIBezierPath(roundedRect: CGRect(origin: origin, size: size), cornerRadius: 4)
		
		self.selectionLayer.path = path.cgPath
	}
	
	override func configureAppearance() {
		super.configureAppearance()
		// Override the build-in appearance configuration
		if self.isPlaceholder {
			self.eventIndicator.isHidden = true
			self.titleLabel.textColor = UIColor.lightGray
		}
	}
}
