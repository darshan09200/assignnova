//
//  UIViewController+Keyboard.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-04.
//

import UIKit
import Connectivity
import FirebaseAnalytics
import Network

extension UIViewController{
	static func swizzle() {
		
		// make sure this isn't a subclass
		if self !== UIViewController.self {
			return
		}
		
		swizzleViewWillAppear()
		swizzleViewWillDisappear()
	}
	
	private static func swizzleViewWillAppear(){
		let originalSelector = #selector(UIViewController.viewWillAppear(_:))
		let swizzledSelector = #selector(UIViewController._swizzled_viewWillAppear(_:))
		
		let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector)
		let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
		
		
		method_exchangeImplementations(originalMethod!, swizzledMethod!);
	}
	
	private static func swizzleViewWillDisappear(){
		let originalSelector = #selector(UIViewController.viewWillDisappear(_:))
		let swizzledSelector = #selector(UIViewController._swizzled_viewWillDisappear(_:))
		
		let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector)
		let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
		
		
		method_exchangeImplementations(originalMethod!, swizzledMethod!);
	}
	
	@objc func _swizzled_viewWillAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
		NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name:UIResponder.keyboardWillHideNotification, object: self.view.window)
		
		getScrollViews().forEach{
			$0.keyboardDismissMode = .interactive
			$0.alwaysBounceVertical = true
		}
		
		let offlineView = UIStackView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: self.navigationController?.navigationBar.frame.height ?? 32))
		let label = UILabel()
		label.text = "Device is offline"
		offlineView.addArrangedSubview(label)
		offlineView.isLayoutMarginsRelativeArrangement = true
		offlineView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		offlineView.backgroundColor = .systemYellow
		
		Analytics.logEvent(AnalyticsEventScreenView, parameters: [
			AnalyticsParameterScreenClass: String(describing: self),
			AnalyticsParameterScreenName: self.navigationItem.title ?? "Unknown"
		])
		
		let monitor = NWPathMonitor()
		
		monitor.pathUpdateHandler = {path in
			DispatchQueue.main.async {
				self.navigationItem.title?.replace(" - Offline", with: "")
				if path.status != .satisfied{
					if let title = self.navigationItem.title{
						self.navigationItem.title = title + " - Offline"
					} else {
						self.navigationItem.title = "Offline"
					}
				}
			}
		}
		
		let queue = DispatchQueue(label: "Network")
		monitor.start(queue: queue)
		
//
		
//		NotificationCenter.default.addObserver(self, selector: #selector(onUpdateConnectionStatus), name: .ConnectivityDidChange, object: offlineView)
		
		_swizzled_viewWillAppear(animated)
	}
	
	@objc func onUpdateConnectionStatus(notification: NSNotification) {
		print("notif")
		let connectivity = notification.object as? Connectivity
		switch connectivity?.status{
			case .connected: fallthrough
			case .connectedViaCellular: fallthrough
			case .connectedViaEthernet: fallthrough
			case .connectedViaWiFi:
				(notification.object as? UIView)?.removeFromSuperview()
			case .connectedViaEthernetWithoutInternet: fallthrough
			case .connectedViaCellularWithoutInternet: fallthrough
			case .connectedViaWiFiWithoutInternet: fallthrough
			case .determining: fallthrough
			case .notConnected: fallthrough
			case .none:
				if let offlineView = notification.object as? UIView{
					self.navigationController?.navigationBar.addSubview(offlineView)
				}
		}
	}
	
	@objc func _swizzled_viewWillDisappear(_ animated: Bool){
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)

		_swizzled_viewWillDisappear(animated)
	}
	
	private func getScrollViews() -> [UIScrollView]{
		return self.view.subviews.filter{$0 is UIScrollView}.compactMap{$0 as? UIScrollView}
	}
	
	@objc func adjustForKeyboard(notification: Notification) {
		guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
		
		let keyboardScreenEndFrame = keyboardValue.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
		
		let scrollViews = getScrollViews()
		if notification.name == UIResponder.keyboardWillHideNotification {
			scrollViews.forEach{$0.contentInset = .zero}
		} else {
			scrollViews.forEach{$0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)}
		}
		
		scrollViews.forEach{$0.scrollIndicatorInsets = $0.contentInset}

	}
	
}
