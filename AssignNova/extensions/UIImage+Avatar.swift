//
//  UIImage+Avatar.swift
//  AssignNova
//
//  Created by Darshan Jain on 2023-03-25.
//

import UIKit
import LetterAvatarKit

extension UIImage{
	static func makeLetterAvatar(withName name: String, backgroundColor: UIColor? = nil) -> (UIImage?, UIColor) {
		var avatarBackgroundColor: UIColor
		let configuration = LetterAvatarBuilderConfiguration()
		configuration.circle = true
		configuration.username = name
		if let backgroundColor = backgroundColor{
			avatarBackgroundColor = backgroundColor
		} else{
			let colors = ColorPickerVC.colors.filter{$0.forAvatar}.compactMap{$0.color}
			var colorIndex = 0
			let usernameInfo = UsernameInfo(
				username: name
			)
			if colors.count > 1 {
				colorIndex = usernameInfo.ASCIIValue
				colorIndex *= 3557 // Prime number
				colorIndex %= colors.count - 1
			}
			avatarBackgroundColor = colors[colorIndex]
		}
		configuration.backgroundColors = [avatarBackgroundColor]
		return (.makeLetterAvatar(withConfiguration: configuration), avatarBackgroundColor)
	}
}

private class UsernameInfo {
	
	public var letters: String {
		return userInfo.letters
	}
	
	public var ASCIIValue: Int {
		return userInfo.value
	}
	
	private let username: String
	
	private typealias InfoContainer = (letters: String, value: Int)
	private lazy var userInfo: InfoContainer = {
		var letters = String()
		var lettersASCIIValue = 0
		// Obtains an array of words by using a given username
		let components = username.components(separatedBy: " ")
		// If there are whether two words or more
		if components.count > 1 {
			for component in components.prefix(3) {
				if let letter = component.first {
					letters.append(letter)
					lettersASCIIValue += letter.ASCIIValue
				}
			}
		} else {
			// If given just one word
			if let component = components.first {
				// Process the firs name letter
				if let letter = component.first {
					letters.append(letter)
					lettersASCIIValue += letter.ASCIIValue
					// If single Letter is passed as false but the string is a single char,
					// this line fails due to out of bounds exception.
					// https://github.com/vpeschenkov/LetterAvatarKit/issues/11
					if component.count >= 2 {
						// Process the second name letter
						let startIndex = component.index(after: component.startIndex)
						let endIndex = component.index(component.startIndex, offsetBy: 2)
						let substring = component[startIndex..<endIndex].capitalized
						if let letter = substring.first {
							letters.append(letter)
							lettersASCIIValue += letter.ASCIIValue
						}
					}
				}
			}
		}
		return (letters: letters, value: lettersASCIIValue)
	}()
	
	init(username: String) {
		self.username = username
	}
}

private extension Character {
	
	var ASCIIValue: Int {
		let unicode = String(self).unicodeScalars
		return Int(unicode[unicode.startIndex].value)
	}
}
