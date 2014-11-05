//
//  Extensions.swift
//  SwiftCalc
//
//  Created by Krin-San on 27.10.14.
//

import Foundation


extension Double {
	var rad: Double { return self * M_PI / 180.0 }

	func toString() -> String {
		// TODO: Use better formatter
		return String(format: "%.1f", self)
	}
}

extension String {

	func toDouble(unsafe: Bool = false) -> Double? {
		var result = NSNumberFormatter().numberFromString(self)?.doubleValue
		return (unsafe && result == nil) ? 0.0 : result
	}

	func contains(find: String) -> Bool {
		return (self.rangeOfString(find) != nil)
	}

	// MARK: - Subtring

	func substringToIndex(index:Int) -> String {
		return self.substringToIndex(advance(self.startIndex, index))
	}

	func substringFromIndex(index:Int) -> String {
		return self.substringFromIndex(advance(self.startIndex, index))
	}
}


func address<T: Any>(o: T) -> String {
	return String(format: "%p", unsafeBitCast(o, Int.self))
}
