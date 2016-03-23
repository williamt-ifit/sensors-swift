//
//  Service.swift
//  SwiftySensors
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals


public protocol ServiceProtocol {
    static var uuid: String { get }
    static var serviceType: Service.Type { get }
}

public class Service {
    
    public weak var sensor: Sensor!
    
    public let cbService: CBService
    
    public internal(set) var characteristics = Dictionary<String, Characteristic>()
        
    internal var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return Dictionary()
    }
    
    public func findCharacteristic<T: Characteristic>() -> T? {
        for characteristic in characteristics.values {
            if let c = characteristic as? T {
                return c
            }
        }
        return nil
    }
    
    required public init(sensor: Sensor, cbs: CBService) {
        self.sensor = sensor
        self.cbService = cbs
    }
    
}