//
//  CyclingSpeedCadenceService.swift
//  SwiftySensors
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

//
// https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.cycling_speed_and_cadence.xml
//
public class CyclingSpeedCadenceService: Service, ServiceProtocol {
    public static var uuid: String { return "1816" }
    public static var serviceType: Service.Type { return self }
    public override var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return [
            Measurement.uuid:   Measurement.self,
            Feature.uuid:       Feature.self,
        ]
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.csc_measurement.xml
    //
    public class Measurement: Characteristic {
        static var uuid: String { return "2A5B" }
        
        public private(set) var speedKPH: Double?
        public private(set) var crankRPM: Double?
        
        public var wheelCircumferenceCM: Double = 213.3
        
        public private(set) var currentMeasurement: CyclingSpeedCadenceSerializer.MeasurementData? {
            didSet {
                guard let previous = oldValue else { return }
                guard let current = currentMeasurement else { return }
                speedKPH = CyclingSerializer.calculateWheelKPH(current, previous: previous, wheelCircumferenceCM: wheelCircumferenceCM)
                crankRPM = CyclingSerializer.calculateCrankRPM(current, previous: previous)
            }
        }
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        deinit {
            cbCharacteristic.notify(false)
        }
        
        override func valueUpdated() {
            if let value = cbCharacteristic.value {
                currentMeasurement = CyclingSpeedCadenceSerializer.readMeasurement(value)
            }
            super.valueUpdated()
        }
        
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.cycling_power_feature.xml
    //
    public class Feature: Characteristic {
        static var uuid: String { return "2A5C" }
        
        public private(set) var features: CyclingSpeedCadenceSerializer.Features?
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.read()
        }
        
        override func valueUpdated() {
            if let value = cbCharacteristic.value {
                features = CyclingSpeedCadenceSerializer.readFeatures(value)
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
        static var uuid: String { return "2A5D" }
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.read()
        }
        
        public private(set) var location: CyclingSerializer.SensorLocation?
        
        override func valueUpdated() {
            if let value = cbCharacteristic.value {
                location = CyclingSerializer.readSensorLocation(value)
            }
            super.valueUpdated()
        }
    }
    
    
}


