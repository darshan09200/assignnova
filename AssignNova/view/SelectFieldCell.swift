//
//  SelectFieldCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit

@objc protocol SelectFieldDelegate {
	func onDonePress(cell: SelectFieldCell)
	@objc optional func onOpen(cell: SelectFieldCell)
}

class SelectFieldCell: UITableViewCell {

	let dummy = UITextField(frame: .zero)
	
	var picker: UIPickerView? {
		didSet{
			print("added default")
			dummy.inputView = picker
		}
	}
	var datePicker: UIDatePicker?{
		didSet{
			dummy.inputView = datePicker
		}
	}
	var delegate: SelectFieldDelegate?

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var selectButton: UIButton!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		addSubview(dummy)
		picker = UIPickerView()
		let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
		
		let items = [flexSpace, doneButton]
		toolbar.items = items
		toolbar.sizeToFit()
		
		dummy.inputAccessoryView = toolbar
		
		selectionStyle = .none
		
    }
	
	@IBAction func onSelectPress(_ sender: Any) {
		delegate?.onOpen?(cell: self)
		dummy.becomeFirstResponder()
	}
	
	@objc func doneButtonTapped(){
		dummy.resignFirstResponder()
		delegate?.onDonePress(cell: self)
	}
	
}
