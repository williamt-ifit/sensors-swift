//
//  CyclingPowerSensor.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

//
// https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.cycling_power.xml
//
public class CyclingPowerService: Service, ServiceProtocol {
    public static var uuid: String { return "1818" }
    public static var serviceType: Service.Type { return self }
    public override var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return [
            Measurement.uuid:       Measurement.self,
            Feature.uuid:           Feature.self,
            SensorLocation.uuid:    SensorLocation.self,
            ControlPoint.uuid:      ControlPoint.self,
            WahooTrainer.uuid:      WahooTrainer.self,
        ]
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.cycling_power_measurement.xml
    //
    public class Measurement: Characteristic {
        public static let uuid: String = "2A63"
        
        public private(set) var instantaneousPower: UInt?
        public private(set) var speedKPH: Double?
        public private(set) var crankRPM: Double?
        
        public var wheelCircumferenceCM: Double = 213.3
        
        public private(set) var currentMeasurement: CyclingPowerSerializer.MeasurementData? {
            didSet {
                guard let current = currentMeasurement else { return }
                instantaneousPower = UInt(current.instantaneousPower)
                
                guard let previous = oldValue else { return }
                speedKPH = CyclingSerializer.calculateWheelKPH(current, previous: previous, wheelCircumferenceCM: wheelCircumferenceCM, wheelTimeResolution: 2048)
                crankRPM = CyclingSerializer.calculateCrankRPM(current, previous: previous)
            }
        }
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override public func valueUpdated() {
            if let value = cbCharacteristic.value {
                currentMeasurement = CyclingPowerSerializer.readMeasurement(value)
            }
            super.valueUpdated()
        }
        
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.cycling_power_feature.xml
    //
    public class Feature: Characteristic {
        public static let uuid: String = "2A65"
        
        public private(set) var features: CyclingPowerSerializer.Features?
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.read()
        }
        
        override public func valueUpdated() {
            if let value = cbCharacteristic.value {
                features = CyclingPowerSerializer.readFeatures(value)
            }
            
            super.valueUpdated()
            
            if let service = service {
                service.sensor.onServiceFeaturesIdentified => (service.sensor, service)
            }
        }
    }
    
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.sensor_location.xml
    //
    public class SensorLocation: Characteristic {
        public static let uuid: String = "2A5D"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.read()
        }
        
        public private(set) var location: CyclingSerializer.SensorLocation?
        
        override public func valueUpdated() {
            if let value = cbCharacteristic.value {
                location = CyclingSerializer.readSensorLocation(value)
            }
            super.valueUpdated()
        }
    }
    
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.cycling_power_control_point.xml
    //
    // TODO: Pretty much all of this ...
    public class ControlPoint: Characteristic {
        public static let uuid: String = "2A66"
        static let writeType = CBCharacteristicWriteType.WithResponse
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override public func valueUpdated() {
            // TODO: Process this response
            super.valueUpdated()
        }
    }
    
}


