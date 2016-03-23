//
//  Characteristic.swift
//  SwiftySensors
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

public class Characteristic {
    
    public weak var service: Service?
    
    public let onValueUpdated = Signal<Characteristic>()
    public let onValueWritten = Signal<Characteristic>()
    
    public let cbCharacteristic: CBCharacteristic
    
    public private(set) var valueUpdatedTimestamp: Double?
    public private(set) var valueWrittenTimestamp: Double?
    
    required public init(service: Service, cbc: CBCharacteristic) {
        self.service = service
        self.cbCharacteristic = cbc
    }
    
    internal func valueUpdated() {
        valueWrittenTimestamp = NSDate.timeIntervalSinceReferenceDate()
        onValueUpdated.fire(self)
    }
    
    internal func valueWritten() {
        valueUpdatedTimestamp = NSDate.timeIntervalSinceReferenceDate()
        onValueWritten.fire(self)
    }
    
    public var value: NSData? {
        return cbCharacteristic.value
    }
    
}

public class UTF8Characteristic: Characteristic {
    
    public var stringValue: String? {
        if let value = value {
            return String(data: value, encoding: NSUTF8StringEncoding)
        }
        return nil
    }
    
    required public init(service: Service, cbc: CBCharacteristic) {
        super.init(service: service, cbc: cbc)
        
        cbCharacteristic.read()
    }
    
}

extension NSData {
    
    static func fromIntArray(int8s: [UInt8]) -> NSData {
        return NSData(bytes: int8s, length: int8s.count)
    }
    
}