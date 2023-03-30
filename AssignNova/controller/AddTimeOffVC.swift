//
//  AddTimeOffVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-30.
//

import UIKit

class AddTimeOffVC: UIViewController {

	@IBOutlet weak var allDaySwitch: UISwitch!
	
	@IBOutlet weak var startDateLabel: UILabel!
	
	@IBOutlet weak var endDateStack: UIStackView!
	@IBOutlet weak var timeStack: UIStackView!
	
	@IBOutlet weak var notesTextInput: TextInput!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
	@IBAction func onAllDayChanged(_ sender: UISwitch) {
		if sender.isOn {
			timeStack.isHidden = true
			endDateStack.isHidden = false
		} else {
			timeStack.isHidden = false
			endDateStack.isHidden = true
		}
	}
	
	@IBAction func onStartDatePress(_ sender: UIButton) {
	}
	
	@IBAction func onEndDatePress(_ sender: UIButton) {
	}
	
	@IBAction func onSelectTimePress(_ sender: UIButton) {
	}
	
}
