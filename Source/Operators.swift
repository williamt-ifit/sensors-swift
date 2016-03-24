//
//  Operators.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import Foundation

public extension SignedIntegerType {
    public mutating func increment() {
        self = self.successor()
    }
    
    public mutating func decrement() {
        self = self.predecessor()
    }
}

prefix operator ++= { }
public prefix func ++= <T: SignedIntegerType>(inout v: T) -> T {
    v.increment()
    return v
}

postfix operator ++= { }
public postfix func ++= <T: SignedIntegerType>(inout v: T) -> T {
    let result = v
    v.increment()
    return result
}

prefix operator --= { }
public prefix func --= <T: SignedIntegerType>(inout v: T) -> T {
    v.decrement()
    return v
}

postfix operator --= { }
public postfix func --= <T: SignedIntegerType>(inout v: T) -> T {
    let result = v
    v.decrement()
    return result
}