//
//  SCEquationObject.swift
//  SwiftCalc
//
//  Created by Krin-San on 27.10.14.
//

import Foundation


typealias OperationPerformType = ([Double]) -> (Double?)


// Base object to store in calculator math core's input array
public class SCEquationObject: DebugPrintable {

	var stringValue: String

	// DebugPrintable protocol
	public var debugDescription: String { return stringValue }

	init(_ _string: String) {
		stringValue = _string
	}

}

// Operand to store numerica values
public class SCOperand: SCEquationObject {

	convenience init() {
		self.init("")
	}

	internal func input(value: String) -> Bool {
		var retval: Bool = true

		if let button = KeypadButton(rawValue: value) {
			switch button {
			case .Dot:
				// Avoid inserting more than one dot
				if !stringValue.contains(value) {
					stringValue += value
				}
			case .Backspace:
				retval = backspace()
			default:
				assert(false, "You shall not pass, <\(button)>!")
			}
		}
		else {
			stringValue += value
		}

		return retval
	}

	internal func backspace() -> Bool {
		var retval: Bool = true
		var size = countElements(stringValue)

		if (size > 0) {
			stringValue = stringValue.substringToIndex(size - 1)
		} else {
			retval = false
		}

		return retval
	}

}

public class SCOperation : SCEquationObject {

	let priority: Priority
	let operandsCount: Int
	private let performBlock: OperationPerformType


	init(_ _string: String, priority _priority: Priority, operandsCount _count: Int, performBlock _block: OperationPerformType) {
		priority = _priority
		operandsCount = _count
		performBlock = _block
		super.init(_string)
	}

	internal func perform(operands: [Double]) -> Double? {
		return (operandsCount == InfiniteOperands || operands.count == operandsCount)
			? performBlock(operands)
			: nil
	}
	
}
