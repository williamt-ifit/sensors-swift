//
//  CyclingSpeedCadenceService.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
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
    public override var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return [
            Measurement.uuid:       Measurement.self,
            Feature.uuid:           Feature.self,
            SensorLocation.uuid:    SensorLocation.self,
        ]
    }
    
    public var measurement: Measurement?
    public var feature: Feature?
    public var sensorLocation: SensorLocation?
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.csc_measurement.xml
    //
    public class Measurement: Characteristic {
        public static let uuid: String = "2A5B"
        
        public private(set) var speedKPH: Double?
        public private(set) var crankRPM: Double?
        
        public var wheelCircumferenceCM: Double = 213.3
        
        public private(set) var measurementData: CyclingSpeedCadenceSerializer.MeasurementData? {
            didSet {
                guard let previous = oldValue else { return }
                guard let current = measurementData else { return }
                
                if let kph = CyclingSerializer.calculateWheelKPH(current, previous: previous, wheelCircumferenceCM: wheelCircumferenceCM, wheelTimeResolution: 1024) {
                    speedKPH = kph
                }
                if let rpm = CyclingSerializer.calculateCrankRPM(current, previous: previous) {
                    crankRPM = rpm
                }
            }
        }
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? CyclingSpeedCadenceService)?.measurement = self
            
            cbCharacteristic.notify(true)
        }
        
        override public func valueUpdated() {
            if let value = cbCharacteristic.value {
                
                // Certain sensors (*cough* Mio Velo *cough*) will send updates in bursts
                // so we're going to do a little filtering here to get a more stable reading
                
                let now = NSDate.timeIntervalSinceReferenceDate()
                // calculate the expected interval of wheel events based on current speed
                // This results in a small "bump" of speed typically at the end. need to fix that...
                var reqInterval = 0.8
                if let speedKPH = speedKPH {
                    let speedCMS = speedKPH * 27.77777777777778
                    // A slower speed of around 5 kph would expect a wheel event every 1.5 seconds.
                    // These values could probably use some tweaking ...
                    reqInterval = max(0.5, min((wheelCircumferenceCM / speedCMS) * 0.9, 1.5))
                }
                if measurementData == nil || now - measurementData!.timestamp > reqInterval {
                    measurementData = CyclingSpeedCadenceSerializer.readMeasurement(value)
                }
            }
            super.valueUpdated()
        }
        
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.cycling_power_feature.xml
    //
    public class Feature: Characteristic {
        public static let uuid: String = "2A5C"
        
        public private(set) var features: CyclingSpeedCadenceSerializer.Features?
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? CyclingSpeedCadenceService)?.feature = self
            
            cbCharacteristic.read()
        }
        
        override public func valueUpdated() {
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
        public static let uuid: String = "2A5D"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? CyclingSpeedCadenceService)?.sensorLocation = self
            
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
    
    
}


