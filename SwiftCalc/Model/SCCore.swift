//
//  SCCore.swift
//  SwiftCalc
//
//  Created by Krin-San on 30.10.14.
//

import Foundation


public class SCCore {

	// Singleton
	class func sharedInstance() -> SCCore {
		struct _Singleton {
			static let instance = SCCore()
		}

		return _Singleton.instance
	}


	var expression: [SCEquationObject] = []
	var result: Double = 0.0 {
		didSet {
			notify()
		}
	}

	private func parseExpression() -> String {
		var description = ""

		if (expression.count == 0) {
			description = "0"
		} else {
			for item in expression {
				description += item.stringValue
			}
		}

		return description
	}

	private func notify(_ error: String? = nil) {
		var userInfo: [String: String] = [
			kCoreValueExpression: parseExpression(),
			kCoreValueResult: result.toString(),
		]
		if error != nil {
			userInfo[kCoreValueError] = error!

			// Prepare for next expression
			expression.removeAll()
		}

		NSNotificationCenter.defaultCenter().postNotificationName(kCoreValuesChangedNotification, object: self, userInfo: userInfo)
	}

	func reset() {
		expression.removeAll()
		result = 0.0
	}

	func input(part: Any) {
		if let obj = part as? SCEquationObject {
			expression.append(obj)
		}
		else if let obj = part as? String {
			if let operand = expression.last as? SCOperand {
				// Append new part to existing operand
				if !operand.input(obj) {
					expression.removeLast()
				}
			}
			else {
				// Append part to newly created operand
				var operand = SCOperand()
				if operand.input(obj) {
					expression.append(operand)
				}
			}
		}
		else {
			assert(false, "Unhandled class of equation part <\(part)>")
		}

		notify()
	}

	func calculate() {
		// Translate to reverse polish notation

		var opn:       [SCEquationObject] = []
		var opStack:   [SCEquationObject] = []

		println("INPUT = \(expression)")

		for operand in expression {
//			println("<\(operand.stringValue)>")

			if (operand is SCOperand) {
//				println("<\(operand.stringValue)> ADD  >> OPN")
				opn.append(operand)
			} else if (operand is SCOperation) {
				while !opStack.isEmpty && (opStack.last is SCOperation) && ((opStack.last as SCOperation).priority.rawValue >= (operand as SCOperation).priority.rawValue) {
//					println("<\(operand.stringValue)> POP  \(opStack.last!.stringValue) >> OPN")
					opn.append(opStack.last!)
					opStack.removeLast()
				}

//				println("<\(operand.stringValue)> PUSH")
				opStack.append(operand)
			} else {
				if (operand.stringValue == specialOperators[.OpeningBracket]?.stringValue) {
//					println("<\(operand.stringValue)> PUSH")
					opStack.append(operand)
				} else if (operand.stringValue == specialOperators[.ClosingBracket]?.stringValue) {
					var isFoundOpeningBracket: Bool = false

					for obj in opStack.reverse() {
						if (obj.stringValue == specialOperators[.OpeningBracket]?.stringValue) {
//							println("<\(operand.stringValue)> POP")
							isFoundOpeningBracket = true
						} else {
//							println("<\(operand.stringValue)> POP  >> OPN")
							opn.append(obj)
						}

						opStack.removeLast()

						if (isFoundOpeningBracket) {
							break
						}
					}

					if (!isFoundOpeningBracket) {
						notify("Unbalanced brackets!")
						return
					}
				} else {
					assert(false, "Unhandled operand <\(operand.stringValue)>")
				}
			}
		}

		for operand in opStack.reverse() {
//			println("<\(operand.stringValue)> MOVE >> OPN")
			opn.append(operand)
		}
		opStack.removeAll()

		println("OPN   = \(opn)")

		// Calculate

		var variables: [Double] = []

		for operand in opn {
			if (operand is SCOperand) {
//				println("<\(operand.stringValue)> PUSH")
				variables.append(operand.stringValue.toDouble(unsafe: true)!)
			} else if let operation = operand as? SCOperation {
				if (variables.count < operation.operandsCount) {
					println("<\(operand.stringValue)> CALC = nil (Failed)")
					notify("Operation <\(operand.stringValue)> failed")
					return
				}

				var range = (variables.count - operation.operandsCount)..<variables.count
				var slice = Array(variables[range])

				if let ans = operation.perform(slice) {
					println("<\(operand.stringValue)> CALC \(slice) = \(ans)")
					variables.removeRange(range)
					variables.append(ans)
				} else {
					println("<\(operand.stringValue)> CALC = nil (Failed)")
					notify("Operation <\(operand.stringValue)> failed")
					return
				}
			} else {
				assert(false, "Unexpected operand <\(operand.stringValue)>")
			}
		}

		result = (variables.first != nil) ? variables.first! : 0.0

		// Prepare for next expression
		expression.removeAll()
	}

}
