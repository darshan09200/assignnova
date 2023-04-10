//
//  SubscriptionDetail.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-08.
//

import UIKit

struct SubscriptionDetailRequest: Encodable{
	var businessId: String
}

struct SubscriptionDetail: Decodable{
	var currentPeriodStart: TimeInterval
	var currentPeriodEnd: TimeInterval
	var renewalDate: TimeInterval
	var subscriptionStartDate: TimeInterval
	var trialEnd: TimeInterval
	var quantity: Int
	var paymentMethod: PaymentMethod?
}

struct PaymentMethod: Decodable{
	var last4: String
	var expMonth: Int
	var expYear: Int
	var funding: String
	var brand: String
	var country: String
}

