//
//  DeviceInformationService.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth

//
// https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.device_information.xml
//
/// :nodoc:
open class DeviceInformationService: Service, ServiceProtocol {
    
    public static var uuid: String { return "180A" }
    
    override open var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return [
            ManufacturerName.uuid:  ManufacturerName.self,
            ModelNumber.uuid:       ModelNumber.self,
            SerialNumber.uuid:      SerialNumber.self,
            HardwareRevision.uuid:  HardwareRevision.self,
            FirmwareRevision.uuid:  FirmwareRevision.self,
            SoftwareRevision.uuid:  SoftwareRevision.self,
            SystemID.uuid:          SystemID.self,
        ]
    }
    
    open private(set) var manufacturerName: ManufacturerName?
    open private(set) var modelNumber: ModelNumber?
    open private(set) var serialNumber: SerialNumber?
    open private(set) var hardwareRevision: HardwareRevision?
    open private(set) var firmwareRevision: FirmwareRevision?
    open private(set) var softwareRevision: SoftwareRevision?
    open private(set) var systemID: SystemID?
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.manufacturer_name_string.xml
    //
    open class ManufacturerName: UTF8Characteristic {
        
        public static let uuid: String = "2A29"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.manufacturerName = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.model_number_string.xml
    //
    open class ModelNumber: UTF8Characteristic {
        
        public static let uuid: String = "2A24"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.modelNumber = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.serial_number_string.xml
    //
    open class SerialNumber: UTF8Characteristic {
        
        public static let uuid: String = "2A25"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.serialNumber = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.hardware_revision_string.xml
    //
    open class HardwareRevision: UTF8Characteristic {
        
        public static let uuid: String = "2A27"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.hardwareRevision = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.firmware_revision_string.xml
    //
    open class FirmwareRevision: UTF8Characteristic {
        
        public static let uuid: String = "2A26"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.firmwareRevision = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.software_revision_string.xml
    //
    open class SoftwareRevision: UTF8Characteristic {
        
        public static let uuid: String = "2A28"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.softwareRevision = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.software_revision_string.xml
    //
    open class SystemID: Characteristic {
        
        public static let uuid: String = "2A23"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.systemID = self
            
            readValue()
        }
    }
    
}
