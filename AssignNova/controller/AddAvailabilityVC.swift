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
	@IBOutlet weak var deleteBtn: UIButton!
	
	@IBOutlet weak var dateBtn: UIButton!
	@IBOutlet weak var timeBtn: UIButton!
	
	var isAvailable = true
	
	@IBOutlet weak var notesField: TextInput!
	
	let dateDummy = UITextField(frame: .zero)
	let datePicker = UIDatePicker()
	
	let timeDummy = UITextField(frame: .zero)
	let timePicker = UIPickerView()
	
	var startDate: Date = .now.startOfDay
	var startTime: Date = .now.getNearest15()
	var endTime: Date = .now.getNearest15().add(minute: 15)
	
	var availability: Availability?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let availability = availability{
			navigationItem.title = "Edit Availability"
			startDate = availability.date
			startTime = availability.startTime
			endTime = availability.endTime
			
			AllDaySwitch.setOn(availability.allDay, animated: true)
			
			allDaySwitchToggled(AllDaySwitch)
			
			isAvailable = availability.isAvailable
			
			if isAvailable{
				availableBtnTapped()
			} else {
				unavailableBtnTapped()
			}
			deleteBtn.isHidden = false
		} else {
			deleteBtn.isHidden = true
		}
		
		availableBtn.addTarget(self, action: #selector(availableBtnTapped), for: .touchUpInside)
		unavailableBtn.addTarget(self, action: #selector(unavailableBtnTapped), for: .touchUpInside)
		
		let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButton))
		
		let items = [flexSpace, doneButton]
		toolbar.items = items
		toolbar.sizeToFit()
		
		dateDummy.inputView = datePicker
		datePicker.minimumDate = .now
		datePicker.datePickerMode = .date
		datePicker.preferredDatePickerStyle = .wheels
		dateDummy.inputAccessoryView = toolbar
		datePicker.date = startDate
		datePicker.addTarget(self, action: #selector(onStartDateValueChanged), for: .valueChanged)
		
		timeDummy.inputView = timePicker
		timePicker.delegate = self
		timePicker.dataSource = self
		timeDummy.inputAccessoryView = toolbar
		
		view.addSubview(dateDummy)
		view.addSubview(timeDummy)
		
		dateBtn.setTitle(startDate.format(to: "EEE, MMM dd, yyyy"), for: .normal)
		timeBtn.setTitle(Date.buildTimeRangeString(startDate: startTime, endDate: endTime), for: .normal)
		
	}
	
	@objc func availableBtnTapped() {
		availableBtn.setImage(UIImage(systemName: "record.circle"), for: .normal)
		availableBtn.tintColor = .blue
		unavailableBtn.setImage(UIImage(systemName: "circle"), for: .normal)
		unavailableBtn.tintColor = .gray
		
		isAvailable = true
	}
	
	@objc func unavailableBtnTapped() {
		availableBtn.setImage(UIImage(systemName: "circle"), for: .normal)
		availableBtn.tintColor = .gray
		unavailableBtn.setImage(UIImage(systemName: "record.circle"), for: .normal)
		unavailableBtn.tintColor = .blue
		
		isAvailable = false
	}
	
	
	@IBAction func onDatePressed(_ sender: UIButton) {
		dateDummy.becomeFirstResponder()
	}
	
	@IBAction func allDaySwitchToggled(_ sender: UISwitch) {
		if sender.isOn{
			timeBtn.isEnabled = false
			timeBtn.setTitle(Date.buildTimeRangeString(startDate: startDate.startOfDay, endDate: startDate.endOfDay), for: .normal)
		} else {
			timeBtn.isEnabled = true
			timeBtn.setTitle(Date.buildTimeRangeString(startDate: startTime, endDate: endTime), for: .normal)
		}
	}
	
	@IBAction func onTimePress(_ sender: UIButton) {
		timeDummy.becomeFirstResponder()
		
		let startTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
		let endTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: endTime)
		
		let startTimeIndex = TimeRangePicker.startTimes.firstIndex(where: {
			let components = Calendar.current.dateComponents([.hour, .year, .minute], from: $0)
			return components.minute == startTimeComponents.minute && components.hour == startTimeComponents.hour
		}) ?? 0
		
		let endTimeIndex = TimeRangePicker.endTimes.firstIndex(where:{
			let components = Calendar.current.dateComponents([.hour, .year, .minute], from: $0)
			return components.minute == endTimeComponents.minute && components.hour == endTimeComponents.hour
		}) ?? 0
		
		timePicker.selectRow(startTimeIndex, inComponent: 0, animated: true)
		timePicker.selectRow(endTimeIndex, inComponent: 1, animated: true)
	}
	
	@IBAction func onCancelPress(_ sender: Any) {
		dismiss(animated: true)
	}
	
	@IBAction func onSavePress(_ sender: Any) {
		let isAllDay = AllDaySwitch.isOn
		let notes = notesField.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines)
		let availability = Availability(id: availability?.id, allDay: isAllDay, isAvailable: isAvailable, date: startDate, startTime: isAllDay ? startDate.startOfDay : startTime, endTime: isAllDay ? startDate.endOfDay : endTime, notes: notes, createdAt: availability?.createdAt)
		self.startLoading()
		FirestoreHelper.saveAvailability(availability){error in
			if let _ = error {
				self.stopLoading(){
					self.showAlert(title: "Oops", message: "Unknown error occured")
				}
				return
			}
			self.stopLoading(){
				self.dismiss(animated: true)
			}
		}
	}
	@IBAction func onAvailabilityPress(_ sender: Any) {
		self.showConfirmation(title: "Warning", message: "Are you sure you want to delete the availability?"){
			self.startLoading()
			FirestoreHelper.deleteAvailability(self.availability!.id!){ error in
				if let _ = error {
					self.stopLoading(){
						self.showAlert(title: "Oops", message: "Unknown error occured")
					}
					return
				}
				self.stopLoading(){
					self.dismiss(animated: true)
				}
			}
		}
	}
}

extension AddAvailabilityVC{
    @objc func onDoneButton(){
		view.endEditing(false)
    }

    @objc func onStartDateValueChanged(_ datePicker: UIDatePicker){
        startDate = datePicker.date
        dateBtn.setTitle(startDate.format(to: "EEE, MMM dd, yyyy"), for: .normal)
    }
	
	
}

extension AddAvailabilityVC: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return TimeRangePicker.numberOfComponents(in: pickerView)
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TimeRangePicker.pickerView(pickerView, numberOfRowsInComponent: component)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TimeRangePicker.pickerView(pickerView, titleForRow: row, forComponent: component)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let (startTime, endTime) = TimeRangePicker.pickerView(pickerView, didSelectRow: row, inComponent: component){
            self.startTime = startTime
            self.endTime = endTime
            timeBtn.setTitle(Date.buildTimeRangeString(startDate: startTime, endDate: endTime), for: .normal)
        }
    }

}
