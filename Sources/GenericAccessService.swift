//
//  GenericAccessService.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth

//
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.generic_access.xml
//
/// :nodoc:
open class GenericAccessService: Service, ServiceProtocol {
    
    public static var uuid: String { return "1800" }

    public static var characteristicTypes: Dictionary<String, Characteristic.Type> = [
        DeviceName.uuid:  DeviceName.self,
        Appearance.uuid:  Appearance.self
    ]
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.gap.device_name.xml
    //
    open class DeviceName: UTF8Characteristic {
        
        public static let uuid: String = "2A00"
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.gap.appearance.xml
    //
    open class Appearance: Characteristic {
        
        public static let uuid: String = "2A00"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            readValue()
        }
    }
    
}
