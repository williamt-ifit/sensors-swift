//
//  DeviceInformationService.swift
//  SwiftySensors
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth

//
// https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.device_information.xml
//
public class DeviceInformationService: Service, ServiceProtocol {
    public static var uuid: String { return "180A" }
    public static var serviceType: Service.Type { return self }
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
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.manufacturer_name_string.xml
    //
    public class ManufacturerName: UTF8Characteristic {
        static var uuid: String { return "2A29" }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.model_number_string.xml
    //
    public class ModelNumber: UTF8Characteristic {
        static var uuid: String { return "2A24" }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.serial_number_string.xml
    //
    public class SerialNumber: UTF8Characteristic {
        static var uuid: String { return "2A25" }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.hardware_revision_string.xml
    //
    public class HardwareRevision: UTF8Characteristic {
        static var uuid: String { return "2A27" }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.firmware_revision_string.xml
    //
    public class FirmwareRevision: UTF8Characteristic {
        static var uuid: String { return "2A26" }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.software_revision_string.xml
    //
    public class SoftwareRevision: UTF8Characteristic {
        static var uuid: String { return "2A28" }
    }
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.software_revision_string.xml
    //
    public class SystemID: Characteristic {
        static var uuid: String { return "2A23" }
    }
    
}
