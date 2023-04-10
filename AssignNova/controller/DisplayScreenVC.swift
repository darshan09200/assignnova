//
//  DisplayScreenVC.swift
//  AssignNova
//
//  Created by PAVIT KALRA on 2023-04-10.
//

import UIKit

class DisplayScreenVC: UIViewController {

    @IBOutlet weak var loginNavBtn: UIButton!
    @IBOutlet weak var signupNavBtn: UIButton!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginNavPressed(_ sender: UIButton) {
        navigationController?.pushViewController(UIStoryboard(name: "SignInScreen", bundle: nil).instantiateViewController(withIdentifier: "SignInVC"), animated: true)
    }
    
    
    @IBAction func signupNavPressed(_ sender: Any) {
        navigationController?.pushViewController(UIStoryboard(name: "DisplayScreen", bundle: nil).instantiateViewController(withIdentifier: "Signupcards"), animated: true)
    }
    

}
