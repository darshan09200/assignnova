//
//  PaymentHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-07.
//

import UIKit
import StripePaymentSheet

class PaymentHelper{
	static func authorizePayment(
		controller: UIViewController,
		paymentDetails: PaymentDetails?,
		preventRefresh: Bool = false,
		completion: @escaping(_ paymentResult: PaymentSheetResult )->()
	) {
		if let paymentDetails = paymentDetails{
			let customerId = paymentDetails.customerId
			let customerEphemeralKeySecret = paymentDetails.ephemeralKey
			let publishableKey = paymentDetails.publishableKey
			
			STPAPIClient.shared.publishableKey = publishableKey
			
			var configuration = PaymentSheet.Configuration()
			configuration.defaultBillingDetails.address = .init(country: "CA", state: "ON")
			configuration.appearance.colors.primary = UIColor(named: "AccentColor")!
			configuration.merchantDisplayName = "AssignNova"
			configuration.savePaymentMethodOptInBehavior = .requiresOptIn
			configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
			configuration.allowsDelayedPaymentMethods = false
			let paymentSheet: PaymentSheet
			if let clientSecret = paymentDetails.setupClientSecret{
				paymentSheet = PaymentSheet(setupIntentClientSecret: clientSecret, configuration: configuration)
			} else if let clientSecret = paymentDetails.paymentClientSecret{
				paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
			} else {
				controller.stopLoading(){
					controller.showAlert(title: "Oops", message: "Error creating subscription")
				}
				return
			}
			controller.stopLoading(){
				paymentSheet.present(from: controller) { paymentResult in
					var title = "Oops"
					var message = ""
					switch paymentResult {
						case .completed:
							title = "Congrats"
							message = "Your order is confirmed"
						case .canceled:
							message = "Canceled!"
						case .failed(let error):
							message = "Payment failed: \(error)"
					}
					controller.showAlert(title: title, message: message){
						if case PaymentSheetResult.completed = paymentResult, !preventRefresh{
							DispatchQueue.main.async {
								(UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.refreshData()
							}
						} else {
							completion(paymentResult)
						}
					}
				}
			}
		} else {
			controller.stopLoading(){
				controller.showAlert(title: "Oops", message: "Error creating subscription")
			}
		}
	}
}
