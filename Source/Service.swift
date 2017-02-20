//
//  Service.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals


public protocol ServiceProtocol: class {
    static var uuid: String { get }
    static var serviceType: Service.Type { get }
}

extension ServiceProtocol where Self: Service {
    public static var serviceType: Service.Type { return self }
}

public func == (lhs: Service, rhs: Service) -> Bool {
    return lhs.cbService.uuid == rhs.cbService.uuid
}

open class Service: Equatable {
    
    open weak var sensor: Sensor!
    
    open let cbService: CBService
    
    public internal(set) var characteristics = Dictionary<String, Characteristic>()
    
    open var characteristicTypes: Dictionary<String, Characteristic.Type> {
        return Dictionary()
    }
    
    open func characteristic<T: Characteristic>(_ uuid: String? = nil) -> T? {
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
