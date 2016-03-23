//
//  HeartRateService.swift
//  SwiftySensors
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

//
// https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.heart_rate.xml
//
public class HeartRateService: Service, ServiceProtocol {
    public static var uuid: String { return "180D" }
    public static var serviceType: Service.Type { return self }
    public override var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return [
            Measurement.uuid:           Measurement.self,
            BodySensorLocation.uuid:    BodySensorLocation.self,
            ControlPoint.uuid:          ControlPoint.self
        ]
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_measurement.xml
    //
    public class Measurement: Characteristic {
        static var uuid: String { return "2A37" }
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
            
            service.sensor.onServiceFeaturesIdentified => (service.sensor, service)
        }
        
        deinit {
            cbCharacteristic.notify(false)
        }
        
        public private(set) var currentMeasurement: HeartRateSerializer.MeasurementData?
        
        override func valueUpdated() {
            if let value = cbCharacteristic.value {
                currentMeasurement = HeartRateSerializer.readMeasurement(value)
            }
            super.valueUpdated()
        }
        
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.body_sensor_location.xml
    //
    public class BodySensorLocation: Characteristic {
        static var uuid: String { return "2A38" }
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.read()
        }
        
        
        public private(set) var location: HeartRateSerializer.BodySensorLocation?
        
        override func valueUpdated() {
            if let value = cbCharacteristic.value {
                location = HeartRateSerializer.readSensorLocation(value)
            }
            super.valueUpdated()
        }
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_control_point.xml
    //
    public class ControlPoint: Characteristic {
        static var uuid: String { return "2A39" }
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
 
        deinit {
            cbCharacteristic.notify(false)
        }
        
        public func resetEnergyExpended() {
            cbCharacteristic.write(NSData.fromIntArray(HeartRateSerializer.writeResetEnergyExpended()), writeType: .WithResponse)
        }
        
        override func valueUpdated() {
            // TODO: Unsure what value is read from the CP after we reset the energy expended (not documented?)
            super.valueUpdated()
        }
    }
    
}


