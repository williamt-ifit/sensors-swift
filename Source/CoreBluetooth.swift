//
//  CoreBluetooth.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth

extension CBCharacteristic {
    
    public func notify(enabled: Bool) {
        service.peripheral.setNotifyValue(enabled, forCharacteristic: self)
    }
    
    public func read() {
        service.peripheral.readValueForCharacteristic(self)
    }
    
    public func write(data: NSData, writeType: CBCharacteristicWriteType) {
        service.peripheral.writeValue(data, forCharacteristic: self, type: writeType)
    }
    
}
