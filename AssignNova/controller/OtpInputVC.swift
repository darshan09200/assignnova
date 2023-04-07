//
//  OtpInputViewController.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-17.
//

import UIKit
import AEOTPTextField
import FirebaseAuth

protocol OtpInputDelegate {
	func onOtpVerified(credential: PhoneAuthCredential, controller: OtpInputVC)
}

class OtpInputVC: UIViewController {

	@IBOutlet weak var otpTextField: AEOTPTextField!
	
	@IBOutlet weak var topContent: UIStackView!
	@IBOutlet weak var contentView: UIView!
	
	@IBOutlet weak var phoneNumberLabel: UILabel!
	@IBOutlet weak var resendOtpButton: UIButton!
	
	var delegate: OtpInputDelegate?
	
	let phoneNumber = UserDefaults.standard.string(forKey: "authPhoneNumber")
	
	private var timer: Timer?
	private var secondsLeft = 0
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		if let phoneNumber = phoneNumber{
			phoneNumberLabel.isHidden = false
			phoneNumberLabel.text = phoneNumber
		} else {
			phoneNumberLabel.isHidden = true
		}

		otpTextField.otpDelegate = self
		otpTextField.otpFilledBackgroundColor = .systemBlue
		otpTextField.otpFilledBorderColor = .clear
		otpTextField.otpTextColor = .white
		otpTextField.configure()
		
		restartTimer()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		UserDefaults.standard.removeObject(forKey: "authVerificationID")
		UserDefaults.standard.removeObject(forKey: "authPhoneNumber")
		
		super.viewDidDisappear(animated)
	}
	
	@IBAction func onResendOtpPress(_ sender: Any) {
		if let isValid = timer?.isValid, !isValid {
			let phoneNumber = UserDefaults.standard.string(forKey: "authPhoneNumber")
			if let phoneNumber = phoneNumber{
				CloudFunctionsHelper.sendOtp(phoneNumber: phoneNumber){ error in
					if let error = error{
						print(error.localizedDescription)
						return
					}
					self.restartTimer()
				}
			}
		}
	}
	
	func restartTimer(){
		secondsLeft = 30
		resendOtpButton.setTitle("Resend in 00:30", for: .normal)
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCount), userInfo: nil, repeats: true)
		disableResendOtp()
	}
	
	@objc func updateCount(){
		secondsLeft -= 1
		if secondsLeft > 0{
			let minutes = Int(secondsLeft) / 60 % 60
			let seconds = Int(secondsLeft) % 60
			resendOtpButton.setTitle(String(format:"Resend in %02i:%02i", minutes, seconds), for: .normal)
		} else {
			timer?.invalidate()
			enableResendOtp()
			resendOtpButton.setTitle("Resend OTP", for: .normal)
		}
	}
	
	func disableResendOtp(){
		resendOtpButton.isEnabled = false
	}
	
	func enableResendOtp(){
		resendOtpButton.isEnabled = true
	}
}

extension OtpInputVC: AEOTPTextFieldDelegate{
	func didUserFinishEnter(the code: String) {
		
		let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
		if let verificationID = verificationID {
			startLoading()
			let credential = PhoneAuthProvider.provider().credential(
				withVerificationID: verificationID,
				verificationCode: code
			)
			
			if let delegate = delegate {
				delegate.onOtpVerified(credential: credential, controller: self)
			} else {
				dismiss(animated: true)
				stopLoading()
			}
		}
	}
}
