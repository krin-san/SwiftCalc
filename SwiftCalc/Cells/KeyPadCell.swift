//
//  KeyPadCell.swift
//  SwiftCalc
//
//  Created by Krin-San on 05.11.14.
//

import UIKit

class KeyPadCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var titleLabel: UILabel!

	var value: Any? = "" {
		didSet {
			var description: String

			if let obj = value as? SCEquationObject {
				description = obj.stringValue
			} else if let obj = value as? String {
				description = obj
			} else {
				description = "ERR"
			}

			titleLabel.text = description
		}
	}

}
