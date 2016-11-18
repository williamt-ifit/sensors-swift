//
//  Sensor.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

open class Sensor: NSObject {
    
    open let peripheral: CBPeripheral
    open let advertisements: [CBUUID]
    
    open let onNameChanged = Signal<Sensor>()
    open let onStateChanged = Signal<Sensor>()
    
    open let onServiceDiscovered = Signal<(Sensor, Service)>()
    open let onServiceFeaturesIdentified = Signal<(Sensor, Service)>()
    
    open let onCharacteristicDiscovered = Signal<(Sensor, Characteristic)>()
    open let onCharacteristicValueUpdated = Signal<(Sensor, Characteristic)>()
    open let onCharacteristicValueWritten = Signal<(Sensor, Characteristic)>()
    
    
    internal weak var serviceFactory: SensorManager.ServiceFactory?
    
    required public init(peripheral: CBPeripheral, advertisements: [CBUUID] = []) {
        self.peripheral = peripheral
        self.advertisements = advertisements
        
        super.init()
        
        peripheral.delegate = self
        peripheral.addObserver(self, forKeyPath: "state", options: [.new, .old], context: &myContext)
    }
    
    deinit {
        peripheral.removeObserver(self, forKeyPath: "state")
        peripheral.delegate = nil
        rssiPingTimer?.invalidate()
    }
    
    fileprivate var myContext = 0
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if keyPath == "state" {
                peripheralStateChanged()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    fileprivate func peripheralStateChanged() {
        #if os(iOS)
            switch peripheral.state {
            case .connected:
                rssiPingEnabled = true
            case .connecting:
                break
            case .disconnected:
                rssiPingEnabled = false
                services.removeAll()
            case .disconnecting:
                rssiPingEnabled = false
            }
        #else
            switch peripheral.state {
            case .Connected:
                rssiPingEnabled = true
            case .Connecting:
                break
            case .Disconnected:
                rssiPingEnabled = false
                services.removeAll()
            }
        #endif
        SensorManager.logSensorMessage?("Sensor: peripheralStateChanged: \(peripheral.state.rawValue)")
        onStateChanged => self
    }
    
    open fileprivate(set) var services = Dictionary<String, Service>()
    
    
    open func service<T: Service>(_ uuid: String? = nil) -> T? {
        if let uuid = uuid {
            return services[uuid] as? T
        }
        for service in services.values {
            if let s = service as? T {
                return s
            }
        }
        return nil
    }
    
    open func advertisedService(_ uuid: String) -> Bool {
        let service = CBUUID(string: uuid)
        for advertisement in advertisements {
            if advertisement.isEqual(service) {
                return true
            }
        }
        return false
    }
    
    fileprivate func serviceDiscovered(_ cbs: CBService) {
        if let service = services[cbs.uuid.uuidString], service.cbService == cbs {
            return
        }
        if let ServiceType = serviceFactory?.serviceTypes[cbs.uuid.uuidString] {
            let service = ServiceType.init(sensor: self, cbs: cbs)
            services[cbs.uuid.uuidString] = service
            onServiceDiscovered => (self, service)
            let charUUIDs: [CBUUID] = service.characteristicTypes.keys.map { uuid in
                return CBUUID(string: uuid)
            }
            SensorManager.logSensorMessage?("Sensor: Service Created: \(service)")
            peripheral.discoverCharacteristics(charUUIDs, for: cbs)
        }
    }
    fileprivate func characteristicDiscovered(_ cbc: CBCharacteristic, cbs: CBService) {
        guard let service = services[cbs.uuid.uuidString] else { return }
        if let characteristic = service.characteristic(cbc.uuid.uuidString), characteristic.cbCharacteristic == cbc {
            return
        }
        
        if let CharType = service.characteristicTypes[cbc.uuid.uuidString] {
            let characteristic = CharType.init(service: service, cbc: cbc)
            service.characteristics[cbc.uuid.uuidString] = characteristic
            
            characteristic.onValueUpdated.subscribe(on: self) { [weak self] c in
                if let s = self {
                    s.onCharacteristicValueUpdated => (s, c)
                }
            }
            characteristic.onValueWritten.subscribe(on: self) { [weak self] c in
                if let s = self {
                    s.onCharacteristicValueWritten => (s, c)
                }
            }
            
            SensorManager.logSensorMessage?("Sensor: Characteristic Created: \(characteristic)")
            onCharacteristicDiscovered => (self, characteristic)
        }
    }
    
    
    
    
    
    // MARK: RSSI Stuff
    open let onRSSIChanged = Signal<(Sensor, Int)>()
    
    open internal(set) var rssi: Int = Int.min {
        didSet {
            onRSSIChanged => (self, rssi)
        }
    }
    
    fileprivate var rssiPingEnabled: Bool = false {
        didSet {
            if rssiPingEnabled {
                if rssiPingTimer == nil {
                    rssiPingTimer = Timer.scheduledTimer(timeInterval: SensorManager.RSSIPingInterval, target: self, selector: #selector(Sensor.rssiPingTimerHandler), userInfo: nil, repeats: true)
                }
            } else {
                rssi = Int.min
                rssiPingTimer?.invalidate()
                rssiPingTimer = nil
            }
        }
    }
    
    fileprivate var rssiPingTimer: Timer?
    
    func rssiPingTimerHandler() {
        if peripheral.state == .connected {
            peripheral.readRSSI()
        }
    }
    
    
    
    // MARK: Track last
    open fileprivate(set) var lastSensorActivity: Double = Date.timeIntervalSinceReferenceDate
    internal func markSensorActivity() {
        lastSensorActivity = Date.timeIntervalSinceReferenceDate
    }
    
}





extension Sensor: CBPeripheralDelegate {
    
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        onNameChanged => self
        markSensorActivity()
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let cbss = peripheral.services else { return }
        for cbs in cbss {
            serviceDiscovered(cbs)
        }
        markSensorActivity()
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let cbcs = service.characteristics else { return }
        for cbc in cbcs {
            characteristicDiscovered(cbc, cbs: service)
        }
        markSensorActivity()
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let service = services[characteristic.service.uuid.uuidString] else { return }
        guard let char = service.characteristics[characteristic.uuid.uuidString] else { return }
        if char.cbCharacteristic !== characteristic {
            char.cbCharacteristic = characteristic
        }
        char.valueUpdated()
        markSensorActivity()
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let service = services[characteristic.service.uuid.uuidString] else { return }
        guard let char = service.characteristics[characteristic.uuid.uuidString] else { return }
        if char.cbCharacteristic !== characteristic {
            char.cbCharacteristic = characteristic
        }
        char.valueWritten()
        markSensorActivity()
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if RSSI.intValue < 0 {
            rssi = RSSI.intValue
            markSensorActivity()
        }
    }
    
}

