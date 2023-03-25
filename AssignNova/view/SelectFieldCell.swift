//
//  SelectFieldCell.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-23.
//

import UIKit

protocol SelectFieldDelegate {
	func onDonePress(cell: SelectFieldCell)
}

class SelectFieldCell: UITableViewCell {

	let picker = UIPickerView()
	var delegate: SelectFieldDelegate?

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var selectButton: UIButton!
	
	private let dummy = UITextField(frame: .zero)
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		addSubview(dummy)
		
		dummy.inputView = picker
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
		dummy.becomeFirstResponder()
	}
	
	@objc func doneButtonTapped(){
		dummy.resignFirstResponder()
		delegate?.onDonePress(cell: self)
	}
	
}
