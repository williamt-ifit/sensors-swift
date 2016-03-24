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
    
    func notify(enabled: Bool) {
        service.peripheral.setNotifyValue(enabled, forCharacteristic: self)
    }
    
    func read() {
        service.peripheral.readValueForCharacteristic(self)
    }
    
    func write(data: NSData, writeType: CBCharacteristicWriteType) {
        service.peripheral.writeValue(data, forCharacteristic: self, type: writeType)
    }
}
