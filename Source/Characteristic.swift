//
//  Characteristic.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

open class Characteristic {
    
    open fileprivate(set) weak var service: Service?
    
    open let onValueUpdated = Signal<Characteristic>()
    open let onValueWritten = Signal<Characteristic>()
    
    open internal(set) var cbCharacteristic: CBCharacteristic!
    
    open fileprivate(set) var valueUpdatedTimestamp: Double?
    open fileprivate(set) var valueWrittenTimestamp: Double?
    
    required public init(service: Service, cbc: CBCharacteristic) {
        self.service = service
        self.cbCharacteristic = cbc
    }
    
    open func valueUpdated() {
        valueUpdatedTimestamp = Date.timeIntervalSinceReferenceDate
        onValueUpdated => self
    }
    
    open func valueWritten() {
        valueWrittenTimestamp = Date.timeIntervalSinceReferenceDate
        onValueWritten => self
    }
    
    open var value: Data? {
        return cbCharacteristic.value
    }
    
}

open class UTF8Characteristic: Characteristic {
    
    open var stringValue: String? {
        if let value = value {
            return String(data: value, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
    required public init(service: Service, cbc: CBCharacteristic) {
        super.init(service: service, cbc: cbc)
        
        cbCharacteristic.read()
    }
    
}

extension Data {
    
    public static func fromIntArray(_ int8s: [UInt8]) -> Data {
        return Data(bytes: UnsafePointer<UInt8>(int8s), count: int8s.count)
    }
    
}
