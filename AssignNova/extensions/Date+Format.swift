//
//  Date+Format.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-26.
//

import UIKit

extension Date{
	func format(to format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
}
