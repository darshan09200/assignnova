//
//  AddAvailabilityVC.swift
//  AssignNova
//
//  Created by PAVIT KALRA on 2023-03-22.
//

import UIKit

class AddAvailabilityVC: UIViewController{

    @IBOutlet weak var AllDaySwitch: UISwitch!
    @IBOutlet weak var unavailableBtn: UIButton!
    @IBOutlet weak var availableBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    
    @IBOutlet weak var notesField: TextInput!
    
    let datePicker = UIDatePicker() // Create a date picker instance
        
    override func viewDidLoad() {
            super.viewDidLoad()
            
            availableBtn.addTarget(self, action: #selector(availableBtnTapped), for: .touchUpInside)
            unavailableBtn.addTarget(self, action: #selector(unavailableBtnTapped), for: .touchUpInside)
        
        // Add a tap gesture recognizer to the timeLbl
               let timeTapGesture = UITapGestureRecognizer(target: self, action: #selector(showTimeIntervalPicker))
               timeLbl.isUserInteractionEnabled = true
               timeLbl.addGestureRecognizer(timeTapGesture)
        }
            
        @objc func availableBtnTapped() {
            availableBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            availableBtn.tintColor = .blue
            unavailableBtn.setImage(UIImage(systemName: "circle"), for: .normal)
            unavailableBtn.tintColor = .gray
        }
            
        @objc func unavailableBtnTapped() {
            availableBtn.setImage(UIImage(systemName: "circle"), for: .normal)
            availableBtn.tintColor = .gray
            unavailableBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            unavailableBtn.tintColor = .blue
        }
            
    @objc func showTimeIntervalPicker() {
            // Create an alert controller instance
            let alertController = UIAlertController(title: "Select Time Interval", message: nil, preferredStyle: .alert)

        // Create a horizontal stack view to hold the time pickers
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.distribution = .fillEqually
                stackView.spacing = 12
                stackView.translatesAutoresizingMaskIntoConstraints = false

                // Create a start time picker instance
                let startTimePicker = UIDatePicker()
                startTimePicker.datePickerMode = .time
                startTimePicker.minuteInterval = 15
                stackView.addArrangedSubview(startTimePicker)

                // Create an end time picker instance
                let endTimePicker = UIDatePicker()
                endTimePicker.datePickerMode = .time
                endTimePicker.minuteInterval = 15
                stackView.addArrangedSubview(endTimePicker)

                // Add the stack view to the alert controller
                alertController.view.addSubview(stackView)

                // Set up constraints for the stack view
                let margin: CGFloat = 20
                let _: CGFloat = 20
                NSLayoutConstraint.activate([
                    stackView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: margin),
                    stackView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: margin),
                    stackView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -margin),
                    stackView.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -margin)
                ])
        
            // Add an "OK" button to the alert controller
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                self.timeLbl.text = dateFormatter.string(from: startTimePicker.date) + " - " + dateFormatter.string(from: endTimePicker.date)
            }
            alertController.addAction(okAction)

            // Add a "Cancel" button to the alert controller
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            // Present the alert controller
            present(alertController, animated: true, completion: nil)
        }
    
    @IBAction func allDaySwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
                timeLbl.text = "12:00 AM - 11:59 PM"
                timeLbl.isUserInteractionEnabled = false
            } else {
                timeLbl.isUserInteractionEnabled = true
            }
    }
    
    
}
