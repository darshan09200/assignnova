//
//  LoadingView.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-19.
//

import UIKit

class UILoadingView : UIView {
	var spinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
	
	override init(frame rect: CGRect) {
		super.init(frame: rect)
		
		self.backgroundColor = .black.withAlphaComponent(0.75)
		
		self.spinner.color = .white
		self.spinner.startAnimating()
		self.addSubview(self.spinner)
		
		self.autoresizingMask = [.flexibleWidth, .flexibleHeight];
		self.setNeedsLayout()
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func layoutSubviews() {
		self.spinner.center = self.center
		
		var spinnerFrame: CGRect = self.spinner.frame
		let totalWidth: CGFloat = spinnerFrame.size.width + 5
		spinnerFrame.origin.x = self.bounds.origin.x + (self.bounds.size.width - totalWidth) / 2
		self.spinner.frame = spinnerFrame
	}
	
}
