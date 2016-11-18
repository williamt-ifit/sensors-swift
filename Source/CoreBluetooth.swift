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
    
    public func notify(_ enabled: Bool) {
        service.peripheral.setNotifyValue(enabled, for: self)
    }
    
    public func read() {
        service.peripheral.readValue(for: self)
    }
    
    public func write(_ data: Data, writeType: CBCharacteristicWriteType) {
        service.peripheral.writeValue(data, for: self, type: writeType)
    }
    
}
