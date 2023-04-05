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
    
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var timeBtn: UIButton!
    
    
    @IBOutlet weak var notesField: TextInput!
    
    let DateDummy = UITextField(frame: .zero)
    let DatePicker = UIDatePicker()
        
    let timeDummy = UITextField(frame: .zero)
    let timePicker = UIPickerView()
    
    var startDate: Date = .now.startOfDay
    var endDate: Date = .now.startOfDay
    var startTime: Date = .now.getNearest15()
    var endTime: Date = .now.getNearest15().add(minute: 15)
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
        availableBtn.addTarget(self, action: #selector(availableBtnTapped), for: .touchUpInside)
        unavailableBtn.addTarget(self, action: #selector(unavailableBtnTapped), for: .touchUpInside)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButton))

        let items = [flexSpace, doneButton]
        toolbar.items = items
        toolbar.sizeToFit()
        
        DateDummy.inputView = DatePicker
        DatePicker.minimumDate = .now
        DatePicker.datePickerMode = .date
        DatePicker.preferredDatePickerStyle = .wheels
        DateDummy.inputAccessoryView = toolbar
        DatePicker.addTarget(self, action: #selector(onStartDateValueChanged), for: .valueChanged)


        timeDummy.inputView = timePicker
        timePicker.delegate = self
        timePicker.dataSource = self
        timeDummy.inputAccessoryView = toolbar

        view.addSubview(DateDummy)
        view.addSubview(timeDummy)


        dateBtn.setTitle(startDate.format(to: "EEE, MMM dd, yyyy"), for: .normal)
        timeBtn.setTitle(Date.buildTimeRangeString(startDate: startTime, endDate: endTime), for: .normal)
        
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
            
   
    @IBAction func onDatePressed(_ sender: UIButton) {
        DateDummy.becomeFirstResponder()
    }
    
    @IBAction func allDaySwitchToggled(_ sender: UISwitch) {
       
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
    
}

extension AddAvailabilityVC{
    @objc func onDoneButton(){
        self.DateDummy.resignFirstResponder()
        self.timeDummy.resignFirstResponder()
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
