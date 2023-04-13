//
//  SceneDelegate.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-17.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	var preventRefresh = false

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let windowScene = (scene as? UIWindowScene) else { return }
		window?.windowScene = windowScene

		let storyboard = UIStoryboard(name: "DecoyLaunchScreen", bundle: nil)
		let initialViewController = storyboard.instantiateViewController(withIdentifier: "LaunchScreen")
		window?.rootViewController = initialViewController

		window?.backgroundColor = UIColor.white.withAlphaComponent(0)

		window?.makeKeyAndVisible()
	}

	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.

		// Save changes in the application's managed object context when the application transitions to the background.
		(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
	}

	func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
		guard let window = self.window else {
			return
		}

		// change the root view controller to your specific view controller
		window.rootViewController = vc

		if animated {
			UIView.transition(with: window,
							  duration: 0.5,
							  options: .transitionCrossDissolve,
							  animations: nil,
							  completion: nil)
		}
	}
	
	func onRefresh(){
		if let activeEmployee = ActiveEmployee.instance {
			print(activeEmployee.employee)
			if activeEmployee.employee.appRole == .owner && activeEmployee.business == nil {
				let storyboard = UIStoryboard(name: "SignUpBusiness", bundle: nil)
				let initialViewController = storyboard.instantiateViewController(withIdentifier: "SetupBusinessVC") as! SetupBusinessVC
				initialViewController.showLogout = true
				let navigationController = UINavigationController(rootViewController: initialViewController)
				navigationController.navigationBar.prefersLargeTitles = true
				self.changeRootViewController(navigationController, animated: true)
			} else {
				let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
				let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeNavVC")
				self.changeRootViewController(initialViewController, animated: true)
			}
		} else {
			let storyboard = UIStoryboard(name: "DisplayScreen", bundle: nil)
			let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginNavVC")
			self.changeRootViewController(initialViewController, animated: true)
		}
	}

	func refreshData(){
		preventRefresh = false
		CloudFunctionsHelper.refreshData(){ activeEmployee in
			self.onRefresh()
		}
	}

	func addAuthListener(navigateDirectly: Bool = false){
		preventRefresh = navigateDirectly
		Auth.auth().addStateDidChangeListener { auth, user in
			if !self.preventRefresh {
				self.refreshData()
			}
		}
	}

}
