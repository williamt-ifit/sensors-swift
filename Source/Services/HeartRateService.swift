//
//  HeartRateService.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
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
    public override var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return [
            Measurement.uuid:           Measurement.self,
            BodySensorLocation.uuid:    BodySensorLocation.self,
            ControlPoint.uuid:          ControlPoint.self
        ]
    }
    
    public var measurement: Measurement?
    public var bodySensorLocation: BodySensorLocation?
    public var controlPoint: ControlPoint?
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_measurement.xml
    //
    public class Measurement: Characteristic {
        public static let uuid: String = "2A37"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? HeartRateService)?.measurement = self
            
            cbCharacteristic.notify(true)
            
            service.sensor.onServiceFeaturesIdentified => (service.sensor, service)
        }
        
        public private(set) var currentMeasurement: HeartRateSerializer.MeasurementData?
        
        override public func valueUpdated() {
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
        public static let uuid: String = "2A38"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? HeartRateService)?.bodySensorLocation = self
            
            cbCharacteristic.read()
        }
        
        
        public private(set) var location: HeartRateSerializer.BodySensorLocation?
        
        override public func valueUpdated() {
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
        public static let uuid: String = "2A39"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? HeartRateService)?.controlPoint = self
            
            cbCharacteristic.notify(true)
        }
        
        public func resetEnergyExpended() {
            cbCharacteristic.write(NSData.fromIntArray(HeartRateSerializer.writeResetEnergyExpended()), writeType: .WithResponse)
        }
        
        override public func valueUpdated() {
            // TODO: Unsure what value is read from the CP after we reset the energy expended (not documented?)
            super.valueUpdated()
        }
    }
    
}


