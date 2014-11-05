//
//  Operations.swift
//  SwiftCalc
//
//  Created by Krin-San on 30.10.14.
//

import Foundation

// MARK: - Enumerations

public enum KeypadButton: String {
	case Dot       = "."
	case Calculate = "="
	case Backspace = "⌫"
	case Reset     = "C"
}

public enum SpecialOperator: Int {
	case OpeningBracket = 1
	case ClosingBracket
}

public enum OperationCode: Int {
	case Add      = 1
	case Subtract
	case Multiply
	case Divide
	case Pow
	case Sqrt
	case Sin
	case Cos
}

public enum Priority: Int {
	case Low = 0
	case Medium
	case High
}

// MARK: - Operations

public let specialOperators: [SpecialOperator: SCEquationObject] = [
	.OpeningBracket: SCEquationObject("("),
	.ClosingBracket: SCEquationObject(")"),
]

public let operationsList: [OperationCode: SCOperation] = [
	.Add: SCOperation("+", priority: .Low, operandsCount: 2)         { return $0[0] + $0[1] },
	.Subtract: SCOperation("-", priority: .Low, operandsCount: 2)    { return $0[0] - $0[1] },
	.Multiply: SCOperation("*", priority: .Medium, operandsCount: 2) { return $0[0] * $0[1] },
	.Divide: SCOperation("/", priority: .Medium, operandsCount: 2)   { return $0[0] / $0[1] },
	.Pow: SCOperation("^", priority: .High, operandsCount: 2)        { return pow($0[0], $0[1]) },
	.Sqrt: SCOperation("√", priority: .High, operandsCount: 1)       { return sqrt($0[0]) },
	.Sin: SCOperation("Sin", priority: .High, operandsCount: 1)      { return sin($0[0].rad) },
	.Cos: SCOperation("Cos", priority: .High, operandsCount: 1)      { return cos($0[0].rad) },
]
