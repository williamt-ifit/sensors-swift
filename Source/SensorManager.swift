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

open class SensorManager: NSObject {
    
    
    // This is a lazy instance. You can opt to NOT call it and control the lifecycle of the SensorManager yourself if desired
    // No internal reference is made to this instance.
    open static let instance = SensorManager()
    
    // All SensorManager logging is directed through this closure. Set it to nil to turn logging off...
    // ... or set your own closure at the project level to direct all logging to your logger of choice.
    open static var logSensorMessage: ((_: String) -> ())? = { message in
        print(message)
    }
    
    open let onBluetoothStateChange = Signal<CBCentralManagerState>()
    open let onSensorDiscovered = Signal<Sensor>()
    open let onSensorConnected = Signal<Sensor>()
    open let onSensorConnectionFailed = Signal<Sensor>()
    open let onSensorDisconnected = Signal<(Sensor, NSError?)>()
    open let onSensorRemoved = Signal<Sensor>()
    
    
    public enum ManagerState {
        case off
        case idle
        case passiveScan
        case aggressiveScan
    }
    
    open var state: ManagerState = .off {
        didSet {
            if oldValue != state {
                stateUpdated()
            }
        }
    }
    
    open func removeInactiveSensors(_ inactiveTime: TimeInterval) {
        let now = Date.timeIntervalSinceReferenceDate
        for sensor in sensors {
            if now - sensor.lastSensorActivity > inactiveTime {
                if let sensor = sensorsById.removeValue(forKey: sensor.peripheral.identifier.uuidString) {
                    onSensorRemoved => sensor
                }
            }
        }
    }
    
    open var SensorType: Sensor.Type = Sensor.self
    fileprivate let serviceFactory = ServiceFactory()
    internal class ServiceFactory {
        fileprivate(set) var serviceTypes = Dictionary<String, Service.Type>()

        var serviceUUIDs: [CBUUID] {
            return serviceTypes.keys.map { uuid in
                return CBUUID(string: uuid)
            }
        }
        
        var servicesToDiscover: [CBUUID] = []
    }
    
    fileprivate(set) var centralManager: CBCentralManager!
    
    open var sensors: [Sensor] {
        return Array(sensorsById.values)
    }
    
    init(powerAlert: Bool = false) {
        super.init()
        
        let options: [String: AnyObject] = [
            CBCentralManagerOptionShowPowerAlertKey: powerAlert as AnyObject
        ]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }
    
    open func addServiceTypes(_ serviceTypes: [ServiceProtocol.Type]) {
        for type in serviceTypes {
            serviceFactory.serviceTypes[type.uuid] = type.serviceType
        }
    }
    
    open func setServicesToScanFor(_ serviceTypes: [ServiceProtocol.Type]) {
        addServiceTypes(serviceTypes)
        serviceFactory.servicesToDiscover = serviceTypes.map { type in
            return CBUUID(string: type.uuid)
        }
    }
    
    open func disconnectFromSensor(_ sensor: Sensor) {
        SensorManager.logSensorMessage?("SensorManager: Disconnecting from sensor ...")
        centralManager.cancelPeripheralConnection(sensor.peripheral)
    }
    
    open func connectToSensor(_ sensor: Sensor) {
        SensorManager.logSensorMessage?("SensorManager: Connecting to sensor ...")
        centralManager.connect(sensor.peripheral, options: nil)
    }
    
    fileprivate var sensorsById = Dictionary<String, Sensor>()
    fileprivate var activityUpdateTimer: Timer?
    static internal let RSSIPingInterval: TimeInterval = 2
    static internal let ActivityInterval: TimeInterval = 5
    static internal let InactiveInterval: TimeInterval = 4
}

// Private Funtionality
extension SensorManager {
    
    fileprivate func stateUpdated() {
        if centralManager.state != .poweredOn { return }
        
        activityUpdateTimer?.invalidate()
        activityUpdateTimer = nil
        
        switch state {
        case .off:
            stopScan()
            
            for sensor in sensors {
                disconnectFromSensor(sensor)
            }
            SensorManager.logSensorMessage?("Shutting Down SensorManager")
            
        case .idle:
            stopScan()
            startActivityTimer()
            
        case .passiveScan:
            scan(false)
            startActivityTimer()
            
        case .aggressiveScan:
            scan(true)
            startActivityTimer()
        }
    }
    
    fileprivate func stopScan() {
        centralManager.stopScan()
    }
    
    fileprivate func startActivityTimer() {
        activityUpdateTimer?.invalidate()
        activityUpdateTimer = Timer.scheduledTimer(timeInterval: SensorManager.ActivityInterval, target: self, selector: #selector(SensorManager.rssiUpateTimerHandler(_:)), userInfo: nil, repeats: true)
    }
    
    fileprivate func scan(_ aggressive: Bool) {
        let options: [String: AnyObject] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: aggressive as AnyObject
        ]
        let serviceUUIDs = serviceFactory.servicesToDiscover
        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
        SensorManager.logSensorMessage?("SensorManager: Scanning for Services")
        for peripheral in centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs) {
            let _ = sensorForPeripheral(peripheral, create: true)
        }
    }
    
    
    func rssiUpateTimerHandler(_ timer: Timer) {
        let now = Date.timeIntervalSinceReferenceDate
        for sensor in sensors {
            if now - sensor.lastSensorActivity > SensorManager.InactiveInterval {
                sensor.rssi = Int.min
            }
        }
    }
    
    fileprivate func sensorForPeripheral(_ peripheral: CBPeripheral, create: Bool, advertisements: [CBUUID] = []) -> Sensor? {
        if let sensor = sensorsById[peripheral.identifier.uuidString] {
            return sensor
        }
        if !create {
            return nil
        }
        let sensor = SensorType.init(peripheral: peripheral, advertisements: advertisements)
        sensor.serviceFactory = serviceFactory
        sensorsById[peripheral.identifier.uuidString] = sensor
        onSensorDiscovered => sensor
        SensorManager.logSensorMessage?("SensorManager: Created Sensor for Peripheral: \(peripheral)")
        return sensor
    }
    
}



extension SensorManager: CBCentralManagerDelegate {
    
    public func centralManager(_ manager: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        SensorManager.logSensorMessage?("CBCentralManager: didFailToConnectPeripheral: \(peripheral)")
        if let sensor = sensorForPeripheral(peripheral, create: false) {
            onSensorConnectionFailed => sensor
        }
    }
    
    public func centralManager(_ manager: CBCentralManager, didConnect peripheral: CBPeripheral) {
        SensorManager.logSensorMessage?("CBCentralManager: didConnectPeripheral: \(peripheral)")
        if let sensor = sensorForPeripheral(peripheral, create: true) {
            peripheral.discoverServices(serviceFactory.serviceUUIDs)
            onSensorConnected => sensor
        }
    }
    
    public func centralManager(_ manager: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        SensorManager.logSensorMessage?("CBCentralManager: didDisconnectPeripheral: \(peripheral)")
        
        // Error Codes:
        //  0   = Unknown error. possibly a major crash?
        //  6   = Connection timed out unexpectedly (pulled the battery out, lost connection due to distance)
        //  10  = The connection has failed unexpectedly.
        
        if let sensor = sensorForPeripheral(peripheral, create: false) {
            onSensorDisconnected => (sensor, error as NSError?)
        }
    }
    
    public func centralManager(_ manager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let uuids = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            if let sensor = sensorForPeripheral(peripheral, create: true, advertisements: uuids) {
                if RSSI.intValue < 0 {
                    sensor.rssi = RSSI.intValue
                    sensor.markSensorActivity()
                }
            }
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        SensorManager.logSensorMessage?("centralManagerDidUpdateState: \(central.state.rawValue)")
        switch central.state {
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            break
        case .poweredOn:
            stateUpdated()
        }
        
        onBluetoothStateChange => CBCentralManagerState(rawValue: central.state.rawValue)!
    }
    
}

