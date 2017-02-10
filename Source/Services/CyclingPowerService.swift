//
//  CyclingPowerSensor.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

//
// https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.cycling_power.xml
//
open class CyclingPowerService: Service, ServiceProtocol {
    open static var uuid: String { return "1818" }    
    open override var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return [
            Measurement.uuid:       Measurement.self,
            Feature.uuid:           Feature.self,
            SensorLocation.uuid:    SensorLocation.self,
            ControlPoint.uuid:      ControlPoint.self,
            WahooTrainer.uuid:      WahooTrainer.self,
        ]
    }
    
    open var measurement: Measurement?
    open var feature: Feature?
    open var sensorLocation: SensorLocation?
    open var controlPoint: ControlPoint?
    open var wahooTrainer: WahooTrainer?
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.cycling_power_measurement.xml
    //
    open class Measurement: Characteristic {
        open static let uuid: String = "2A63"
        
        open fileprivate(set) var instantaneousPower: UInt?
        open fileprivate(set) var speedKPH: Double?
        open fileprivate(set) var crankRPM: Double?
        
        open var wheelCircumferenceCM: Double = 213.3
        
        open fileprivate(set) var measurementData: CyclingPowerSerializer.MeasurementData? {
            didSet {
                guard let current = measurementData else { return }
                instantaneousPower = UInt(current.instantaneousPower)
                
                guard let previous = oldValue else { return }
                speedKPH = CyclingSerializer.calculateWheelKPH(current, previous: previous, wheelCircumferenceCM: wheelCircumferenceCM, wheelTimeResolution: 2048)
                crankRPM = CyclingSerializer.calculateCrankRPM(current, previous: previous)
            }
        }
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? CyclingPowerService)?.measurement = self
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            // cbCharacteristic is nil?
            if let value = cbCharacteristic.value {
                measurementData = CyclingPowerSerializer.readMeasurement(value)
            }
            super.valueUpdated()
        }
        
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.cycling_power_feature.xml
    //
    open class Feature: Characteristic {
        open static let uuid: String = "2A65"
        
        open fileprivate(set) var features: CyclingPowerSerializer.Features?
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? CyclingPowerService)?.feature = self
            
            cbCharacteristic.read()
        }
        
        override open func valueUpdated() {
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
    open class SensorLocation: Characteristic {
        open static let uuid: String = "2A5D"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? CyclingPowerService)?.sensorLocation = self
            
            cbCharacteristic.read()
        }
        
        open fileprivate(set) var location: CyclingSerializer.SensorLocation?
        
        override open func valueUpdated() {
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
    open class ControlPoint: Characteristic {
        open static let uuid: String = "2A66"
        static let writeType = CBCharacteristicWriteType.withResponse
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? CyclingPowerService)?.controlPoint = self
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            // TODO: Process this response
            super.valueUpdated()
        }
    }
    
}


