//
//  SiriHelper.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-12.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class SiriHelper{
	
	static func getCurrentWeekStats(completion: @escaping(_ message: String?)->()){
		if let receivedData = Keychain.load(key: "employeeId"), let result = receivedData.to(type: String.self){
			getCurrentWeekStats(employeeId: result, completion: completion)
		} else {
			completion("Please login to the application to get details about your shift")
		}
	}
	
	static func getCurrentWeekStats(employeeId: String, completion: @escaping(_ message: String?)->()) {
		print(employeeId)
		
		let request = Shared.call(apiName: "getUpcomingShift", with: ["employeeId": employeeId])
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			if let _ = error {
				completion(nil)
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse,
				  (200...299).contains(httpResponse.statusCode) else {
				completion(nil)
				return
			}
			
			if let data = data,
			   let shiftDetail = try? JSONDecoder().decode(ShiftDetail.self, from: data) {
				if let message = shiftDetail.message{
					completion(message)
				} else {
					completion(nil)
				}
				return
			}
			completion(nil)
		})
		task.resume()
	}
}


struct ShiftDetail: Decodable{
	var message: String?
}

struct Shift: Codable{
	@DocumentID var id: String?
	var businessId: String
	var shiftStartDate: Date
	var shiftStartTime: Date
	var shiftEndTime: Date
	var unpaidBreak: Int?
	var branchId: String
	var roleId: String
	var color: String
	var notes: String?
	var employeeId: String?
	var eligibleEmployees: [String]?
	var noOfOpenShifts: Int?
	var approvalRequired: Bool = false
	var status: Status?
	var attendance: Attendance?
	var acceptedBy: String?{
		didSet{
			acceptedOn = .now
		}
	}
	var acceptedOn: Date?
	var createdBy: String
	@ServerTimestamp var createdAt: Date?
	@ServerTimestamp var updatedAt: Date?
}
