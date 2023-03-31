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
	@IBOutlet weak var startDateBtn: UIButton!
	
	@IBOutlet weak var endDateStack: UIStackView!
	@IBOutlet weak var endDateBtn: UIButton!
	
	@IBOutlet weak var timeStack: UIStackView!
	@IBOutlet weak var shiftTimeBtn: UIButton!
	
	@IBOutlet weak var notesTextInput: TextInput!
	
	let startDateDummy = UITextField(frame: .zero)
	let startDatePicker = UIDatePicker()
	
	let endDateDummy = UITextField(frame: .zero)
	let endDatePicker = UIDatePicker()
	
	let shiftTimeDummy = UITextField(frame: .zero)
	let shiftTimePicker = UIPickerView()
	
	var startDate: Date = .now.startOfDay
	var endDate: Date = .now.startOfDay
	var shiftStartTime: Date = .now.getNearest15()
	var shiftEndTime: Date = .now.getNearest15().add(minute: 15)
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.endDateStack.isHidden = true
		
		let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButton))
		
		let items = [flexSpace, doneButton]
		toolbar.items = items
		toolbar.sizeToFit()
		
		startDateDummy.inputView = startDatePicker
		startDatePicker.minimumDate = .now
		startDatePicker.datePickerMode = .date
		startDatePicker.preferredDatePickerStyle = .wheels
		startDateDummy.inputAccessoryView = toolbar
		startDatePicker.addTarget(self, action: #selector(onStartDateValueChanged), for: .valueChanged)
		
		endDateDummy.inputView = endDatePicker
		endDatePicker.minimumDate = .now
		endDatePicker.datePickerMode = .date
		endDatePicker.preferredDatePickerStyle = .wheels
		endDateDummy.inputAccessoryView = toolbar
		endDatePicker.addTarget(self, action: #selector(onEndDateValueChanged), for: .valueChanged)
		
		shiftTimeDummy.inputView = shiftTimePicker
		shiftTimePicker.delegate = self
		shiftTimePicker.dataSource = self
		shiftTimeDummy.inputAccessoryView = toolbar
		
		view.addSubview(startDateDummy)
		view.addSubview(endDateDummy)
		view.addSubview(shiftTimeDummy)
		
		
		startDateBtn.setTitle(startDate.format(to: "EEE, MMM dd, yyyy"), for: .normal)
		endDateBtn.setTitle(endDate.format(to: "EEE, MMM dd, yyyy"), for: .normal)
		shiftTimeBtn.setTitle(Date.buildTimeRangeString(startDate: shiftStartTime, endDate: shiftEndTime), for: .normal)
    }
    
	@IBAction func onAllDayChanged(_ sender: UISwitch) {
		onDoneButton()
		if sender.isOn {
			self.startDateLabel.text = "Start Date"
			self.timeStack.isHidden = true
			self.endDateStack.isHidden = false
		} else {
			self.startDateLabel.text = "Date"
			self.timeStack.isHidden = false
			self.endDateStack.isHidden = true
		}
	}
	
	@IBAction func onStartDatePress(_ sender: UIButton) {
		startDateDummy.becomeFirstResponder()
	}
	
	@IBAction func onEndDatePress(_ sender: UIButton) {
		endDateDummy.becomeFirstResponder()
	}
	
	@IBAction func onSelectTimePress(_ sender: UIButton) {
		shiftTimeDummy.becomeFirstResponder()
		
		let startTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: shiftStartTime)
		let endTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: shiftEndTime)
		
		let startTimeIndex = TimeRangePicker.startTimes.firstIndex(where: {
			let components = Calendar.current.dateComponents([.hour, .year, .minute], from: $0)
			return components.minute == startTimeComponents.minute && components.hour == startTimeComponents.hour
		}) ?? 0
		
		let endTimeIndex = TimeRangePicker.endTimes.firstIndex(where:{
			let components = Calendar.current.dateComponents([.hour, .year, .minute], from: $0)
			return components.minute == endTimeComponents.minute && components.hour == endTimeComponents.hour
		}) ?? 0
		
		shiftTimePicker.selectRow(startTimeIndex, inComponent: 0, animated: true)
		shiftTimePicker.selectRow(endTimeIndex, inComponent: 1, animated: true)
	}
	
	@IBAction func onSavePress(_ sender: Any) {
		var timeOff = TimeOff(shiftStartDate: startDate, isAllDay: allDaySwitch.isOn, notes: notesTextInput.textFieldComponent.text?.trimmingCharacters(in: .whitespacesAndNewlines))
		if timeOff.isAllDay{
			timeOff.shiftEndDate = endDate
		} else {
			timeOff.shiftStartTime = shiftStartTime
			timeOff.shiftEndTime = shiftEndTime
		}
		self.startLoading()
		FirestoreHelper.createTimeOff(timeOff){ error in
			if let _ = error{
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

extension AddTimeOffVC{
	@objc func onDoneButton(){
		self.startDateDummy.resignFirstResponder()
		self.endDateDummy.resignFirstResponder()
		self.shiftTimeDummy.resignFirstResponder()
	}
	
	@objc func onStartDateValueChanged(_ datePicker: UIDatePicker){
		startDate = datePicker.date
		startDateBtn.setTitle(startDate.format(to: "EEE, MMM dd, yyyy"), for: .normal)
	}
	
	@objc func onEndDateValueChanged(_ datePicker: UIDatePicker){
		endDate = datePicker.date
		endDateBtn.setTitle(endDate.format(to: "EEE, MMM dd, yyyy"), for: .normal)
	}
}

extension AddTimeOffVC: UIPickerViewDelegate, UIPickerViewDataSource{
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
			shiftStartTime = startTime
			shiftEndTime = endTime
			shiftTimeBtn.setTitle(Date.buildTimeRangeString(startDate: shiftStartTime, endDate: shiftEndTime), for: .normal)
		}
	}
	
}
