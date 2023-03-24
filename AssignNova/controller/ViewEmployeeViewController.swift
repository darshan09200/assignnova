//
//  ViewEmployeeViewController.swift
//  AssignNova
//
//  Created by simran mehra on 2023-03-19.
//

import UIKit
import LetterAvatarKit

class ViewEmployeeViewController: UIViewController {
    
   
    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var EmpIdLabel: UILabel!
    @IBOutlet weak var EmpNameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var PhoneLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(addTapped))
        // Circle avatar image with white border
        let circleAvatarImage = LetterAvatarMaker()
            .setCircle(true)
            .setUsername("Letter Avatar")
            .setBorderWidth(1.0)
            .setBackgroundColors([ .red ])
            .build()
        Avatar.image = circleAvatarImage
       
    }
    

    @IBAction func DeleteEmployee(_ sender: Any) {
    }
    
    @IBAction func ViewShifts(_ sender: Any) {
    }
    @objc func addTapped(sender: AnyObject) {
        print("hjxdbsdhjbv")
    }
}
