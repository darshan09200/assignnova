//
//  SignUpEmployeeViewController.swift
//  AssignNova
//
//  Created by PAVIT KALRA on 2023-03-18.
//

import UIKit

class SignUpEmployeeViewController: UIViewController {

    @IBOutlet weak var SignUpModeSegment: UISegmentedControl!
    @IBOutlet weak var emailTxt: TextInput!
    @IBOutlet weak var checkForInviteBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func checkForInviteBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func continueWithGoogleBtnPressed(_ sender: UIButton) {
    }
    
}
