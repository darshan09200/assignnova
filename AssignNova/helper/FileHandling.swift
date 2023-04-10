//
//  FileHandling.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-04-10.
//

import UIKit

class FileHandling{
	
	class func getDirectory() -> URL?{
		do{
			var directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			directory = directory.appending(path: "images")
			if !FileManager.default.fileExists(atPath: directory.path(percentEncoded: false)) {
				try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
				
			}
			return directory
		} catch {
			print("error:", error)
			return nil
		}
	}
	
	class func saveToDirectory(_ image: UIImage) -> String?{
		if let documentsDirectory = getDirectory(){
			let fileName = "\(UUID().uuidString).jpg"
			let fileURL = documentsDirectory.appending(path: fileName)
			do {
				if let data = image.jpegData(compressionQuality:  1),
				   !FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
					try data.write(to: fileURL)
					return fileURL.path(percentEncoded: false)
				}
			} catch {
				print("error:", error)
			}
		}
		return nil
	}
	
	class func saveToDirectory(_ path: String) -> String? {
		if let documentsDirectory = getDirectory(){
			let ogFileUrl = URL(fileURLWithPath: path)
			let fileName = "\(UUID().uuidString).\(ogFileUrl.pathExtension)"
			let fileUrl = documentsDirectory.appending(path: fileName)
			do {
				if FileManager.default.fileExists(atPath: ogFileUrl.path(percentEncoded: false)) {
					try FileManager.default.copyItem(at: ogFileUrl, to: fileUrl)
					return fileUrl.path(percentEncoded: false)
				} else{
					print("Doesnt exist")
				}
			} catch (let error) {
				print("Cannot copy item: \(error.localizedDescription)")
			}
		}
		return nil
		
	}
	
	class func fileExists(_ path: String) -> Bool{
		return FileManager.default.fileExists(atPath: path)
	}
}
