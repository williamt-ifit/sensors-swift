//
//  SensorManager.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

public class SensorManager: NSObject {
    
    // This is a lazy instance. You can opt to NOT call it and control the lifecycle of the SensorManager yourself if desired
    // No internal reference is made to this instance.
    public static let instance = SensorManager()
    
    // All SensorManager logging is directed through this closure. Set it to nil to turn logging off...
    // ... or set your own closure at the project level to direct all logging to your logger of choice.
    public static var logSensorMessage: ((_: String) -> ())? = { message in
        print(message)
    }
    
    public let onBluetoothStateChange = Signal<CBCentralManagerState>()
    public let onSensorDiscovered = Signal<Sensor>()
    public let onSensorConnected = Signal<Sensor>()
    public let onSensorConnectionFailed = Signal<Sensor>()
    public let onSensorDisconnected = Signal<Sensor>()
    public let onSensorRemoved = Signal<Sensor>()
    
    
    public enum ScanMode {
        case Off
        case Passive
        case Aggressive
    }
    
    public var scanMode: ScanMode = .Off {
        didSet {
            if oldValue != scanMode {
                scan()
            }
        }
    }   
    
    
    var SensorType: Sensor.Type = Sensor.self
    private let serviceFactory = ServiceFactory()
    internal class ServiceFactory {
        private(set) var serviceTypes = Dictionary<String, Service.Type>()

        var serviceUUIDs: [CBUUID] {
            return serviceTypes.keys.map { uuid in
                return CBUUID(string: uuid)
            }
        }
        
        var servicesToDiscover: [CBUUID] = []
    }
    
    private(set) var centralManager: CBCentralManager!
    
    public var sensors: [Sensor] {
        return Array(sensorsById.values)
    }
    
    init(powerAlert: Bool = false) {
        super.init()
        
        let options: [String: AnyObject] = [
            CBCentralManagerOptionShowPowerAlertKey: powerAlert
        ]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }
    
    public func addServiceTypes(serviceTypes: [ServiceProtocol.Type]) {
        for type in serviceTypes {
            serviceFactory.serviceTypes[type.uuid] = type.serviceType
        }
    }
    
    public func setServicesToScanFor(serviceTypes: [ServiceProtocol.Type]) {
        addServiceTypes(serviceTypes)
        serviceFactory.servicesToDiscover = serviceTypes.map { type in
            return CBUUID(string: type.uuid)
        }
    }
    
    public func disconnectFromSensor(sensor: Sensor) {
        SensorManager.logSensorMessage?("SensorManager: Disconnecting from sensor ...")
        centralManager.cancelPeripheralConnection(sensor.peripheral)
    }
    
    public func connectToSensor(sensor: Sensor) {
        SensorManager.logSensorMessage?("SensorManager: Connecting to sensor ...")
        centralManager.connectPeripheral(sensor.peripheral, options: nil)
    }
    
    private var sensorsById = Dictionary<String, Sensor>()
}

// Private Funtionality
extension SensorManager {
    
    private func scan() {
        if centralManager.state != .PoweredOn { return }
        
        let allowDuplicateKeys: Bool
        switch scanMode {
        case .Off:
            centralManager.stopScan()
            return
        case .Passive:
            allowDuplicateKeys = false
        case .Aggressive:
            allowDuplicateKeys = true
        }
        let options: [String: AnyObject] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: allowDuplicateKeys
        ]
        let serviceUUIDs = serviceFactory.servicesToDiscover
        centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: options)
        SensorManager.logSensorMessage?("SensorManager: Scanning for Services")
        for peripheral in centralManager.retrieveConnectedPeripheralsWithServices(serviceUUIDs) {
            sensorForPeripheral(peripheral, create: true)
        }
    }
    
    private func sensorForPeripheral(peripheral: CBPeripheral, create: Bool, advertisements: [CBUUID] = []) -> Sensor? {
        if let sensor = sensorsById[peripheral.identifier.UUIDString] {
            return sensor
        }
        if !create {
            return nil
        }
        let sensor = SensorType.init(peripheral: peripheral, advertisements: advertisements)
        sensor.serviceFactory = serviceFactory
        sensorsById[peripheral.identifier.UUIDString] = sensor
        onSensorDiscovered.fire(sensor)
        SensorManager.logSensorMessage?("SensorManager: Created Sensor for Peripheral: \(peripheral)")
        return sensor
    }
    
}



extension SensorManager: CBCentralManagerDelegate {
    
    public func centralManager(manager: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        SensorManager.logSensorMessage?("CBCentralManager: didFailToConnectPeripheral: \(peripheral)")
        if let sensor = sensorForPeripheral(peripheral, create: false) {
            onSensorConnectionFailed.fire(sensor)
        }
    }
    
    public func centralManager(manager: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        SensorManager.logSensorMessage?("CBCentralManager: didConnectPeripheral: \(peripheral)")
        if let sensor = sensorForPeripheral(peripheral, create: true) {
            peripheral.discoverServices(serviceFactory.serviceUUIDs)
            onSensorConnected.fire(sensor)
        }
    }
    
    public func centralManager(manager: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        SensorManager.logSensorMessage?("CBCentralManager: didDisconnectPeripheral: \(peripheral)")
        if let sensor = sensorForPeripheral(peripheral, create: false) {
            onSensorDisconnected.fire(sensor)
        }
    }
    
    public func centralManager(manager: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if let uuids = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            if let sensor = sensorForPeripheral(peripheral, create: true, advertisements: uuids) {
                if RSSI.integerValue < 0 {
                    sensor.rssi = RSSI.integerValue
                }
            }
        }
    }
    
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        SensorManager.logSensorMessage?("centralManagerDidUpdateState: \(central.state.rawValue)")
        switch central.state {
        case .Unknown:
            break
        case .Resetting:
            break
        case .Unsupported:
            break
        case .Unauthorized:
            break
        case .PoweredOff:
            break
        case .PoweredOn:
            scan()
        }
        onBluetoothStateChange.fire(central.state)
    }
    
}

