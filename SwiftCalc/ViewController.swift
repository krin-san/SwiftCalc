//
//  ViewController.swift
//  SwiftCalc
//
//  Created by Krin-San on 27.10.14.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var expressionLabel: UITextField!
	@IBOutlet weak var collection: UICollectionView!

	var basicMatrix:  [[Any]]
	let extraMatrix:  [[Any]]
	var keyPadMatrix: [[Any]] = []

	let cellSpacing = CGFloat(4.0)

	// MARK: - Init

	required init(coder aDecoder: NSCoder) {
		basicMatrix = [
			["7", "8", "9"],
			["4", "5", "6"],
			["1", "2", "3"],
			["0", KeypadButton.Dot.rawValue, KeypadButton.Calculate.rawValue]]
		extraMatrix = [
			[operationsList[.Multiply]!, operationsList[.Divide]!, operationsList[.Add]!, operationsList[.Subtract]!],
			[operationsList[.Pow]!, operationsList[.Sqrt]!, KeypadButton.Backspace.rawValue, KeypadButton.Reset.rawValue],
		]

		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		resultLabel.text = SCCore.sharedInstance().result.toString()
		expressionLabel.text = "0"

		var layout = (collection.collectionViewLayout as UICollectionViewFlowLayout)
		layout.sectionInset = UIEdgeInsetsMake(cellSpacing, cellSpacing, 0.0, cellSpacing)
		layout.minimumInteritemSpacing = cellSpacing
		layout.minimumLineSpacing = cellSpacing

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "coreValuesChanged:", name: kCoreValuesChangedNotification, object: nil)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		layoutKeyPad()
	}

	override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)

		layoutKeyPad()
	}

	// MARK: - SCCore Notifications

	func coreValuesChanged(notification: NSNotification) {
		let userInfo = notification.userInfo!

		println("\(self) \(__FUNCTION__):\(__LINE__) \(userInfo)")

		expressionLabel.text = userInfo[kCoreValueExpression] as String

		if let error = userInfo[kCoreValueError] as? String {
			resultLabel.text = error
		} else {
			resultLabel.text = userInfo[kCoreValueResult] as? String
		}
	}

	// MARK: - UICollectionViewDataSource

	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var count = 0

		for line in keyPadMatrix {
			count += line.count
		}

		return count
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier(buttonReuseID, forIndexPath: indexPath) as KeyPadCollectionViewCell
		var section = 0
		var row = indexPath.row

		for line in keyPadMatrix {
			if row < line.count {
				break
			}

			section++
			row -= line.count
		}

		cell.value = keyPadMatrix[section][row]

		return cell
	}

	// MARK: - UICollectionViewDelegate

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		var cell  = collectionView.cellForItemAtIndexPath(indexPath) as KeyPadCollectionViewCell
		let value = cell.value!
		var core  = SCCore.sharedInstance()

		println("\(self) \(__FUNCTION__):\(__LINE__) \(value)")

		if let obj = value as? String {
			if let button = KeypadButton(rawValue: obj) {
				switch button {
				case .Calculate:
					core.calculate()
				case .Reset:
					core.reset()
				default:
					core.input(value)
				}
			}
			else {
				core.input(value)
			}
		}
		else {
			core.input(value)
		}
	}

	// MARK: - Private functions

	func layoutKeyPad() {
		func insertLine(_ array: [Any]) {
			keyPadMatrix.insert(array, atIndex: 0)
		}

		func insertColumn(_ array: [Any]) {
			for var i = 1; i <= array.count; ++i {
				keyPadMatrix[keyPadMatrix.count - i].append(array[array.count - i])
			}
		}


		println("\(self) \(__FUNCTION__):\(__LINE__) \(collection.frame)")

		// Re-layout keyPad buttons

		keyPadMatrix = basicMatrix

		if collection.frame.size.width > collection.frame.size.height {
			insertColumn(extraMatrix[0])
			insertColumn(extraMatrix[1])
		} else {
			insertColumn(extraMatrix[0])
			insertLine(extraMatrix[1])
		}

		// Set new size for collectionView items

		var layout = (collection.collectionViewLayout as UICollectionViewFlowLayout)
		let lines  = keyPadMatrix.count
		let rows   = { () -> Int in
			var result = 0
			for line in self.keyPadMatrix {
				result = max(result, line.count)
			}
			return result
			}()
		var height = (collection.frame.size.height - CGFloat(2 + lines) * cellSpacing) / CGFloat(lines)
		var width  = (collection.frame.size.width  - CGFloat(2 + rows)  * cellSpacing) / CGFloat(rows)
		layout.itemSize = CGSize(width: width, height: height)
		
		collection.reloadSections(NSIndexSet(index: 0))
	}
	
}
