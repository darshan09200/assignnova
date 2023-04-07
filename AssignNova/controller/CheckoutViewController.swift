//
//  CheckoutViewController.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-05.
//
import UIKit
import StripePaymentSheet

class CheckoutViewController: UIViewController {
	@IBOutlet weak var checkoutButton: UIButton!
	var paymentSheet: PaymentSheet?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		checkoutButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
		checkoutButton.isEnabled = false
		
		// MARK: Fetch the PaymentIntent client secret, Ephemeral Key secret, Customer ID, and publishable key
		let customerId = "cus_NeoPwHxWuavSi4"
		let customerEphemeralKeySecret = "ek_test_YWNjdF8xTXRHOXhBNFZUT3Bpc1hELFFuUGtwWDFBMjJHUE9EaU1nN0s2NVRpTHlYQWVZOGw_00W1QHMF66"
		let setupIntentClientSecret = "seti_1MtXXvA4VTOpisXDbhys83Ak_secret_NerGieKRqXaWiMtnJvCjHQoWW7lLZEh"
		let publishableKey = "pk_test_51MtG9xA4VTOpisXDIPAzJQuqIBqBW5LvxZoPJIUBszJ2hRL9lnMpGl4blXaAGquhFzFsrF31WHnqPPKCydwsW2xQ00wj2aujbE"
		
		STPAPIClient.shared.publishableKey = publishableKey
		// MARK: Create a PaymentSheet instance
		var configuration = PaymentSheet.Configuration()
		configuration.appearance.colors.primary = UIColor(named: "AccentColor")!
		configuration.merchantDisplayName = "Techtoids"
		configuration.savePaymentMethodOptInBehavior = .requiresOptIn
		configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
		configuration.allowsDelayedPaymentMethods = false
		self.paymentSheet = PaymentSheet(setupIntentClientSecret: setupIntentClientSecret, configuration: configuration)
		
		DispatchQueue.main.async {
			self.checkoutButton.isEnabled = true
		}
		
	}
	
	@objc
	func didTapCheckoutButton() {
		// MARK: Start the checkout process
		paymentSheet?.present(from: self) { paymentResult in
			// MARK: Handle the payment result
			switch paymentResult {
				case .completed:
					print("Your order is confirmed")
				case .canceled:
					print("Canceled!")
				case .failed(let error):
					print("Payment failed: \(error)")
			}
		}
	}
}
