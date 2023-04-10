//
//  SignUpCardsVC.swift
//  AssignNova
//
//  Created by PAVIT KALRA on 2023-04-10.
//

import UIKit

class SignUpCardsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

   
    @IBAction func signupemployeebtn(_ sender: UITapGestureRecognizer) {
                let signUpBusinessVC = UIStoryboard(name: "SignUpEmployee", bundle: nil)
                    .instantiateViewController(withIdentifier: "SignUpEmployeeVC") as! SignUpEmployeeVC
                self.navigationController?.pushViewController(signUpBusinessVC, animated: true)
    }
    
    @IBAction func signupbusinessbtn(_ sender: UITapGestureRecognizer) {
        let signUpBusinessVC = UIStoryboard(name: "SignUpBusiness", bundle: nil)
            .instantiateViewController(withIdentifier: "SignUpBusinessAccountVC") as! SignUpBusinessAccountVC
        self.navigationController?.pushViewController(signUpBusinessVC, animated: true)
    }
}
