//
//  ImagePicker.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-10.
//

import UIKit

public protocol ImagePickerDelegate: AnyObject {
	func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {
	
	private let pickerController: UIImagePickerController
	private weak var presentationController: UIViewController?
	private weak var delegate: ImagePickerDelegate?
	
	public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
		self.pickerController = UIImagePickerController()
		
		super.init()
		
		self.presentationController = presentationController
		self.delegate = delegate
		
		self.pickerController.delegate = self
		self.pickerController.allowsEditing = false
		self.pickerController.mediaTypes = ["public.image"]
	}
	
	private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
		guard UIImagePickerController.isSourceTypeAvailable(type) else {
			return nil
		}
		
		return UIAlertAction(title: title, style: .default) { [unowned self] _ in
			self.pickerController.sourceType = type
			self.presentationController?.present(self.pickerController, animated: true)
		}
	}
	
	public func present() {
		
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		if let action = self.action(for: .camera, title: "Take photo") {
			alertController.addAction(action)
		}
		if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
			alertController.addAction(action)
		}
		if let action = self.action(for: .photoLibrary, title: "Photo library") {
			alertController.addAction(action)
		}
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		self.presentationController?.present(alertController, animated: true)
	}
	
	private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
		controller.dismiss(animated: true, completion: nil)
		self.delegate?.didSelect(image: image)
	}
	
	func shareFile(path: String, sourceView: UIView?){
		
		let fileToShare = [ URL(fileURLWithPath: path) ]
		let activityViewController = UIActivityViewController(activityItems: fileToShare, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = sourceView
		presentationController?.present(activityViewController, animated: true, completion: nil)
	}
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.pickerController(picker, didSelect: nil)
	}
	
	public func imagePickerController(_ picker: UIImagePickerController,
									  didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		guard let image = info[.originalImage] as? UIImage else {
			return self.pickerController(picker, didSelect: nil)
		}
		self.pickerController(picker, didSelect: image)
	}
}
