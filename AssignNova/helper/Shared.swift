//
//  Shared.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-12.
//

import UIKit

class Shared{
	static func call(apiName: String, with data: Any)-> URLRequest{
		let url = URL(string:"https://us-central1-assignnova.cloudfunctions.net/\(apiName)")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		do{
			request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
		} catch{}
		
		return request
	}

}
