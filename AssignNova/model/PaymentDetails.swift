//
//  PaymentDetails.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-08.
//

import UIKit

struct PaymentDetails: Decodable{
	var subscriptionId: String
	var setupClientSecret: String?
	var paymentClientSecret: String?
	var ephemeralKey: String
	var customerId: String
	var publishableKey: String
}

