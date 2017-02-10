//
//  HeartRateService.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

//
// https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.heart_rate.xml
//
open class HeartRateService: Service, ServiceProtocol {
    open static var uuid: String { return "180D" }
    open override var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return [
            Measurement.uuid:           Measurement.self,
            BodySensorLocation.uuid:    BodySensorLocation.self,
            ControlPoint.uuid:          ControlPoint.self
        ]
    }
    
    open var measurement: Measurement?
    open var bodySensorLocation: BodySensorLocation?
    open var controlPoint: ControlPoint?
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_measurement.xml
    //
    open class Measurement: Characteristic {
        open static let uuid: String = "2A37"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? HeartRateService)?.measurement = self
            
            cbCharacteristic.notify(true)
            
            service.sensor.onServiceFeaturesIdentified => (service.sensor, service)
        }
        
        open fileprivate(set) var currentMeasurement: HeartRateSerializer.MeasurementData?
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                currentMeasurement = HeartRateSerializer.readMeasurement(value)
            }
            super.valueUpdated()
        }
        
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.body_sensor_location.xml
    //
    open class BodySensorLocation: Characteristic {
        open static let uuid: String = "2A38"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? HeartRateService)?.bodySensorLocation = self
            
            cbCharacteristic.read()
        }
        
        
        open fileprivate(set) var location: HeartRateSerializer.BodySensorLocation?
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                location = HeartRateSerializer.readSensorLocation(value)
            }
            super.valueUpdated()
        }
    }
    
    
    //
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_control_point.xml
    //
    open class ControlPoint: Characteristic {
        open static let uuid: String = "2A39"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? HeartRateService)?.controlPoint = self
            
            cbCharacteristic.notify(true)
        }
        
        open func resetEnergyExpended() {
            cbCharacteristic.write(Data.fromIntArray(HeartRateSerializer.writeResetEnergyExpended()), writeType: .withResponse)
        }
        
        override open func valueUpdated() {
            // TODO: Unsure what value is read from the CP after we reset the energy expended (not documented?)
            super.valueUpdated()
        }
    }
    
}


