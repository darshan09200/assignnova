//
//  LaunchScreenVC.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-22.
//

import UIKit
import FirebaseAuth

class LaunchScreenVC: UIViewController {

	@IBOutlet weak var gradient: UIImageView!
	@IBOutlet weak var logo: UIImageView!

	override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		AuthHelper.refreshData(){ activeEmployee in
			UIView.animate(withDuration: 0.5, delay: activeEmployee == nil ? 0.2 :0, options: .transitionCrossDissolve ,animations: {
				self.logo.transform = CGAffineTransform.identity.scaledBy(x: 50, y: 50)
				self.gradient.alpha = 0
				self.view.backgroundColor = .systemBackground
			}){ finished in
				let delegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
				delegate?.addAuthListener()
			}
		}
	}

}
