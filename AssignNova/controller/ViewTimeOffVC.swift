//
//  ViewTimeOffVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-31.
//

import UIKit
import FirebaseFirestore

class ViewTimeOffVC: UIViewController {

	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var topContent: UIStackView!
	@IBOutlet weak var bottomStack: UIStackView!
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var leftActionButton: UIButton!
	@IBOutlet weak var rightActionButton: UIButton!
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var notesLabel: UILabel!
	@IBOutlet weak var notesContentLabel: UILabel!
	
	private var listener: ListenerRegistration?
	
	var timeOffId: String?
	var timeOff: TimeOff?
	var leftActionType: ActionType = .none
	var rightActionType: ActionType = .none
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
		print(self.topContent.frame.height)
		refreshData()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		listener?.remove()
		
		super.viewDidDisappear(animated)
	}
	
	func refreshData(){
		listener?.remove()
		listener = FirestoreHelper.getTimeOff(timeOffId: timeOffId ?? ""){ timeOff in
			if let timeOff = timeOff{
				self.dateLabel.text = timeOff.startDate.format(to: "EEEE, MMM d, YYYY")
				self.timeLabel.text = Date.buildTimeRangeString(startDate: timeOff.startTime ?? .now, endDate: timeOff.endTime ?? .now)
				if let notes = timeOff.notes, !notes.isEmpty{
					self.notesLabel.isHidden = false
					self.notesContentLabel.isHidden = false
					self.notesContentLabel.text = notes
				} else {
					self.notesLabel.isHidden = true
					self.notesContentLabel.isHidden = true
				}
				if timeOff.status == .pending{
					self.leftActionType = .deny
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Deny", for: .normal)
					self.leftActionButton.tintColor = .systemRed
					
					self.rightActionType = .approve
					self.rightActionButton.isHidden = false
					self.rightActionButton.setTitle("Approve", for: .normal)
					self.rightActionButton.tintColor = UIColor(named: "AccentColor")
				} else if timeOff.status == .approved{
					self.leftActionType = .none
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Approved", for: .normal)
					self.leftActionButton.tintColor = UIColor(named: "AccentColor")
					
					self.rightActionButton.isHidden = true
				} else if timeOff.status == .declined{
					self.leftActionType = .none
					self.leftActionButton.isHidden = false
					self.leftActionButton.setTitle("Declined", for: .normal)
					self.leftActionButton.tintColor = .systemRed
					
					self.rightActionButton.isHidden = true
				} else {
					self.leftActionButton.isHidden = true
					self.rightActionButton.isHidden = true
				}
				
				self.topContent.layoutIfNeeded()
				self.bottomStack.layoutIfNeeded()
				
				print(self.topContent.frame.height)
				print(self.bottomStack.frame.height)
				if self.timeOff == nil{
					self.topConstraint.constant = UIHelper.getTopConstraintToMakeBottom(
						contentView: self.contentView,
						view: self.bottomStack,
						topContentHeight: self.topContent.frame.height,
						navbarHeight: self.navigationController?.navigationBar.frame.height)
				}
				self.timeOff = timeOff
			}
		}
	}
	
	@IBAction func onLeftActionButtonPress(_ sender: Any) {
		if leftActionType == .deny{
			self.startLoading()
			FirestoreHelper.updateTimeOffStatus(timeOffId: timeOffId!, status: .declined){ error in
				if let _ = error{
					self.stopLoading(){
						self.showAlert(title: "Oops", message: "Unknown error occured")
					}
					return
				}
				self.stopLoading()
			}
		}
	}
	
	
	@IBAction func onRightActionButtonPress(_ sender: Any) {
		if rightActionType == .approve{
			self.startLoading()
			FirestoreHelper.updateTimeOffStatus(timeOffId: timeOffId!, status: .approved){ error in
				if let _ = error{
					self.stopLoading(){
						self.showAlert(title: "Oops", message: "Unknown error occured")
					}
					return
				}
				self.stopLoading()
			}
		}
	}
}
