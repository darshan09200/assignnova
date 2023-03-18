//
//  OtpInputViewController.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-17.
//

import UIKit
import AEOTPTextField

class OtpInputViewController: UIViewController {

	@IBOutlet weak var otpTextField: AEOTPTextField!
	
	@IBOutlet weak var verifyOtpButton: UIButton!
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var topContent: UIStackView!
	@IBOutlet weak var contentView: UIView!
	override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationController?.navigationBar.prefersLargeTitles = true

		otpTextField.otpDelegate = self
		otpTextField.otpFilledBackgroundColor = .systemBlue
		otpTextField.otpFilledBorderColor = .clear
		otpTextField.otpTextColor = .white
		otpTextField.configure()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topConstraint.constant = UIHelper.getTopConstraintToMakeBottom(contentView: contentView, view: verifyOtpButton, topContentHeight: topContent.frame.height + 16, navbarHeight: navigationController?.navigationBar.frame.height)
		
		view.layoutIfNeeded()
	}

}

extension OtpInputViewController: AEOTPTextFieldDelegate{
	func didUserFinishEnter(the code: String) {
		print(code)
	}
}

