//
//  DeviceInformationService.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth

//
// https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.device_information.xml
//
public class DeviceInformationService: Service, ServiceProtocol {
    public static var uuid: String { return "180A" }
    public override var characteristicTypes: Dictionary<String, Characteristic.Type> {
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
    
    public var manufacturerName: ManufacturerName?
    public var modelNumber: ModelNumber?
    public var serialNumber: SerialNumber?
    public var hardwareRevision: HardwareRevision?
    public var firmwareRevision: FirmwareRevision?
    public var softwareRevision: SoftwareRevision?
    public var systemID: SystemID?
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.manufacturer_name_string.xml
    //
    public class ManufacturerName: UTF8Characteristic {
        public static let uuid: String = "2A29"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.manufacturerName = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.model_number_string.xml
    //
    public class ModelNumber: UTF8Characteristic {
        public static let uuid: String = "2A24"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.modelNumber = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.serial_number_string.xml
    //
    public class SerialNumber: UTF8Characteristic {
        public static let uuid: String = "2A25"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.serialNumber = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.hardware_revision_string.xml
    //
    public class HardwareRevision: UTF8Characteristic {
        public static let uuid: String = "2A27"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.hardwareRevision = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.firmware_revision_string.xml
    //
    public class FirmwareRevision: UTF8Characteristic {
        public static let uuid: String = "2A26"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.firmwareRevision = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.software_revision_string.xml
    //
    public class SoftwareRevision: UTF8Characteristic {
        public static let uuid: String = "2A28"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.softwareRevision = self
        }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.software_revision_string.xml
    //
    public class SystemID: Characteristic {
        public static let uuid: String = "2A23"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? DeviceInformationService)?.systemID = self
        }
    }
    
}
