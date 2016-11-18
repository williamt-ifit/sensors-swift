//
//  Operators.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import Foundation

public extension SignedInteger {
    public mutating func increment() {
        
        self = self.advanced(by: 1)
    }
    
    public mutating func decrement() {
        self = self.advanced(by: -1)
    }
}

prefix operator ++=
public prefix func ++= <T: SignedInteger>(v: inout T) -> T {
    v.increment()
    return v
}

postfix operator ++=
public postfix func ++= <T: SignedInteger>(v: inout T) -> T {
    let result = v
    v.increment()
    return result
}

prefix operator --=
public prefix func --= <T: SignedInteger>(v: inout T) -> T {
    v.decrement()
    return v
}

postfix operator --=
public postfix func --= <T: SignedInteger>(v: inout T) -> T {
    let result = v
    v.decrement()
    return result
}
