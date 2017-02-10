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
open class DeviceInformationService: Service, ServiceProtocol {
    open static var uuid: String { return "180A" }
    open override var characteristicTypes: Dictionary<String, Characteristic.Type> {
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
    
    open var manufacturerName: ManufacturerName?
    open var modelNumber: ModelNumber?
    open var serialNumber: SerialNumber?
    open var hardwareRevision: HardwareRevision?
    open var firmwareRevision: FirmwareRevision?
    open var softwareRevision: SoftwareRevision?
    open var systemID: SystemID?
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.manufacturer_name_string.xml
    //
    open class ManufacturerName: UTF8Characteristic {
        open static let uuid: String = "2A29"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.manufacturerName = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.model_number_string.xml
    //
    open class ModelNumber: UTF8Characteristic {
        open static let uuid: String = "2A24"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.modelNumber = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.serial_number_string.xml
    //
    open class SerialNumber: UTF8Characteristic {
        open static let uuid: String = "2A25"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.serialNumber = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.hardware_revision_string.xml
    //
    open class HardwareRevision: UTF8Characteristic {
        open static let uuid: String = "2A27"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.hardwareRevision = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.firmware_revision_string.xml
    //
    open class FirmwareRevision: UTF8Characteristic {
        open static let uuid: String = "2A26"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.firmwareRevision = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.software_revision_string.xml
    //
    open class SoftwareRevision: UTF8Characteristic {
        open static let uuid: String = "2A28"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.softwareRevision = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.software_revision_string.xml
    //
    open class SystemID: Characteristic {
        open static let uuid: String = "2A23"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.systemID = self
        }
    }
    
}
