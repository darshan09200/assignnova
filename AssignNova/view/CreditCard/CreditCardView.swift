//
//  CreditCardView.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-08.
//

import UIKit

public class CreditCardView: UIView {
	
	
	public var backgroundView:CCBackgroundView
	var cardContentView:CCContentView
	
	var CONTENT_PADDING:CGFloat = 25
	
	public var nameLabel:UILabel {
		get { return cardContentView.nameLabel }
	}
	
	public var expLabel:UILabel {
		get { return cardContentView.expLabel }
	}
	
	public var numLabel:UILabel {
		get { return cardContentView.numberLabel }
	}
	
	public var brandLabel:UILabel {
		get { return cardContentView.brandLabel }
	}
	
	public var brandImageView:UIImageView {
		get { return cardContentView.brandImageView }
	}
	
	
	public override init(frame: CGRect) {
		backgroundView = CCBackgroundView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
		cardContentView = CCContentView(frame: CGRect(x: CONTENT_PADDING, y: CONTENT_PADDING, width: frame.width - (CONTENT_PADDING * 2), height: frame.height - (CONTENT_PADDING * 2)))
		super.init(frame: frame)
		setupViews()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		backgroundView = CCBackgroundView()
		cardContentView = CCContentView()
		super.init(coder: aDecoder)
		setupViews()
	}
	
	public init(frame: CGRect, template: CCBackgroundView.CCBackgroundTemplate) {
		print(frame)
		backgroundView = CCBackgroundView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), template: template)
		cardContentView = CCContentView(frame: CGRect(x: CONTENT_PADDING, y: CONTENT_PADDING, width: frame.width - (CONTENT_PADDING * 2), height: frame.height - (CONTENT_PADDING * 2)))
		super.init(frame: frame)
		setupViews()
	}
	
	func setupViews() {
		self.addSubview(backgroundView)
		backgroundView.layer.cornerRadius = 10.0
		
		self.addSubview(cardContentView)
	}
	
}

extension CALayer {
	func applySketchShadow(
		color: UIColor = .black,
		alpha: Float = 0.5,
		x: CGFloat = 0,
		y: CGFloat = 2,
		blur: CGFloat = 4,
		spread: CGFloat = 0)
	{
		shadowColor = color.cgColor
		shadowOpacity = alpha
		shadowOffset = CGSize(width: x, height: y)
		shadowRadius = blur / 2.0
		if spread == 0 {
			shadowPath = nil
		} else {
			let dx = -spread
			let rect = bounds.insetBy(dx: dx, dy: dx)
			shadowPath = UIBezierPath(rect: rect).cgPath
		}
	}
}
