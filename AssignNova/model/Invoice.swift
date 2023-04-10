//
//  Invoice.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-08.
//

import UIKit

struct Invoice: Decodable{
	var id: String?
	var hostedUrl: String?
	var pdf: String?
	var paid: Bool
	var invoiceDate: TimeInterval?
	var amountDue: Int
	var amountPaid: Int
	var amountPending: Int
}

struct SubscriptionInvoices: Decodable{
	var invoices: [Invoice]
}
