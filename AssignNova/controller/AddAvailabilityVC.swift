//
//  AddAvailabilityVC.swift
//  AssignNova
//
//  Created by PAVIT KALRA on 2023-03-22.
//

import UIKit

class AddAvailabilityVC: UIViewController {

    @IBOutlet weak var AllDaySwitch: UISwitch!
    @IBOutlet weak var unavailableBtn: UIButton!
    @IBOutlet weak var availableBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    
    @IBOutlet weak var notesField: TextInput!
    
    
    let datePicker = UIDatePicker() // Create a date picker instance
        
    override func viewDidLoad() {
            super.viewDidLoad()
        
        }
        
        
}
