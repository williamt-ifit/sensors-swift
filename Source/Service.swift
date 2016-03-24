//
//  Service.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals


public protocol ServiceProtocol {
    static var uuid: String { get }
    static var serviceType: Service.Type { get }
}

public func == (lhs: Service, rhs: Service) -> Bool {
    return lhs.cbService.UUID == rhs.cbService.UUID
}

public class Service: Equatable {
    
    public weak var sensor: Sensor!
    
    public let cbService: CBService
    
    internal var characteristics = Dictionary<String, Characteristic>()
    
    public var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return Dictionary()
    }
    
    public func characteristic<T: Characteristic>(uuid: String? = nil) -> T? {
        if let uuid = uuid {
            return characteristics[uuid] as? T
        }
        
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