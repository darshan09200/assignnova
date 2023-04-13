//
//  IntentHandler.swift
//  Siri
//
//  Created by Darshan Jain on 2023-04-12.
//

import Intents
import FirebaseCore
import FirebaseAuth


class MyShiftIntentHandler: NSObject, MyShiftIntentHandling{
	func confirm(intent: MyShiftIntent, completion: @escaping (MyShiftIntentResponse) -> Void) {
		completion(MyShiftIntentResponse(code: .ready, userActivity: nil))
	}
	
	func handle(intent: MyShiftIntent, completion: @escaping (MyShiftIntentResponse) -> Void) {
		
		SiriHelper.getCurrentWeekStats(){ message in
			if let message = message{
				completion(.success(shift: message))
			} else {
				completion(.failure(error: "No shift found"))
			}
		}
	}
}


class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
		guard intent is MyShiftIntent else { fatalError("Ask something else") }
		
		FirebaseApp.configure()
		
		do {
			try Auth.auth().useUserAccessGroup(Keychain.accessGroup)
		} catch let error as NSError {
			fatalError("Not logged in")
		}
		
		
        return MyShiftIntentHandler()
    }
    
}
