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

extension UIBezierPath {
	
	convenience init(roundedPolygonPathWithRect rect: CGRect, lineWidth: CGFloat, sides: NSInteger, cornerRadius: CGFloat) {
		
		self.init()
		
		let theta = CGFloat(2.0 * M_PI) / CGFloat(sides)
		let offSet = CGFloat(cornerRadius) / CGFloat(tan(theta/2.0))
		let squareWidth = min(rect.size.width, rect.size.height)
		
		var length = squareWidth - lineWidth
		
		if sides%4 != 0 {
			length = length * CGFloat(cos(theta / 2.0)) + offSet/2.0
		}
		let sideLength = length * CGFloat(tan(theta / 2.0))
		
		var point = CGPoint(x: squareWidth / 2.0 + sideLength / 2.0 - offSet, y: squareWidth - (squareWidth - length) / 2.0)
		var angle = CGFloat(M_PI)
		move(to: point)
		
		for _ in 0 ..< sides {
			point = CGPoint(x: point.x + CGFloat(sideLength - offSet * 2.0) * CGFloat(cos(angle)), y: point.y + CGFloat(sideLength - offSet * 2.0) * CGFloat(sin(angle)))
			addLine(to: point)
			
			let center = CGPoint(x: point.x + cornerRadius * CGFloat(cos(angle + CGFloat(M_PI_2))), y: point.y + cornerRadius * CGFloat(sin(angle + CGFloat(M_PI_2))))
			addArc(withCenter: center, radius:CGFloat(cornerRadius), startAngle:angle - CGFloat(M_PI_2), endAngle:angle + theta - CGFloat(M_PI_2), clockwise:true)
			
			point = currentPoint // we don't have to calculate where the arc ended ... UIBezierPath did that for us
			angle += theta
		}
		
		close()
	}
}
