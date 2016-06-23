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

public class Sensor: NSObject {
    
    public let peripheral: CBPeripheral
    public let advertisements: [CBUUID]
    
    public let onNameChanged = Signal<Sensor>()
    public let onStateChanged = Signal<Sensor>()
    
    public let onServiceDiscovered = Signal<(Sensor, Service)>()
    public let onServiceFeaturesIdentified = Signal<(Sensor, Service)>()
    
    public let onCharacteristicDiscovered = Signal<(Sensor, Characteristic)>()
    public let onCharacteristicValueUpdated = Signal<(Sensor, Characteristic)>()
    public let onCharacteristicValueWritten = Signal<(Sensor, Characteristic)>()
    
    
    internal weak var serviceFactory: SensorManager.ServiceFactory?
    
    required public init(peripheral: CBPeripheral, advertisements: [CBUUID] = []) {
        self.peripheral = peripheral
        self.advertisements = advertisements
        
        super.init()
        
        peripheral.delegate = self
        peripheral.addObserver(self, forKeyPath: "state", options: [.New, .Old], context: &myContext)
    }
    
    deinit {
        peripheral.removeObserver(self, forKeyPath: "state")
        peripheral.delegate = nil
        rssiPingTimer?.invalidate()
    }
    
    private var myContext = 0
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            if keyPath == "state" {
                peripheralStateChanged()
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    
    private func peripheralStateChanged() {
        #if os(iOS)
            switch peripheral.state {
            case .Connected:
                rssiPingEnabled = true
            case .Connecting:
                break
            case .Disconnected:
                rssiPingEnabled = false
                services.removeAll()
            case .Disconnecting:
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
    
    public private(set) var services = Dictionary<String, Service>()
    
    
    public func service<T: Service>(uuid: String? = nil) -> T? {
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
    
    private func serviceDiscovered(cbs: CBService) {
        if let service = services[cbs.UUID.UUIDString] where service.cbService == cbs {
            return
        }
        if let ServiceType = serviceFactory?.serviceTypes[cbs.UUID.UUIDString] {
            let service = ServiceType.init(sensor: self, cbs: cbs)
            services[cbs.UUID.UUIDString] = service
            onServiceDiscovered => (self, service)
            let charUUIDs: [CBUUID] = service.characteristicTypes.keys.map { uuid in
                return CBUUID(string: uuid)
            }
            SensorManager.logSensorMessage?("Sensor: Service Created: \(service)")
            peripheral.discoverCharacteristics(charUUIDs, forService: cbs)
        }
    }
    private func characteristicDiscovered(cbc: CBCharacteristic, cbs: CBService) {
        guard let service = services[cbs.UUID.UUIDString] else { return }
        if let characteristic = service.characteristic(cbc.UUID.UUIDString) where characteristic.cbCharacteristic == cbc {
            return
        }
        
        if let CharType = service.characteristicTypes[cbc.UUID.UUIDString] {
            let characteristic = CharType.init(service: service, cbc: cbc)
            service.characteristics[cbc.UUID.UUIDString] = characteristic
            
            characteristic.onValueUpdated.listen(self) { [weak self] c in
                if let s = self {
                    s.onCharacteristicValueUpdated => (s, c)
                }
            }
            characteristic.onValueWritten.listen(self) { [weak self] c in
                if let s = self {
                    s.onCharacteristicValueWritten => (s, c)
                }
            }
            
            SensorManager.logSensorMessage?("Sensor: Characteristic Created: \(characteristic)")
            onCharacteristicDiscovered => (self, characteristic)
        }
    }
    
    
    
    
    
    // MARK: RSSI Stuff
    public let onRSSIChanged = Signal<(Sensor, Int)>()
    
    public internal(set) var rssi: Int = Int.min {
        didSet {
            onRSSIChanged => (self, rssi)
        }
    }
    
    private var rssiPingEnabled: Bool = false {
        didSet {
            if rssiPingEnabled {
                if rssiPingTimer == nil {
                    rssiPingTimer = NSTimer.scheduledTimerWithTimeInterval(rssiPingInterval, target: self, selector: #selector(Sensor.rssiPingTimerHandler), userInfo: nil, repeats: true)
                }
            } else {
                rssi = Int.min
                rssiPingTimer?.invalidate()
                rssiPingTimer = nil
            }
        }
    }
    
    private var rssiPingTimer: NSTimer?
    
    private let rssiPingInterval: Double = 2
    
    func rssiPingTimerHandler() {
        if peripheral.state == .Connected {
            peripheral.readRSSI()
        }
    }
    
    
    
    // MARK: Track last
    public private(set) var lastSensorActivity: Double = NSDate.timeIntervalSinceReferenceDate()
    private func markSensorActivity() {
        lastSensorActivity = NSDate.timeIntervalSinceReferenceDate()
    }
    
}





extension Sensor: CBPeripheralDelegate {
    
    public func peripheralDidUpdateName(peripheral: CBPeripheral) {
        onNameChanged => self
        markSensorActivity()
    }
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        guard let cbss = peripheral.services else { return }
        for cbs in cbss {
            serviceDiscovered(cbs)
        }
        markSensorActivity()
    }
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        guard let cbcs = service.characteristics else { return }
        for cbc in cbcs {
            characteristicDiscovered(cbc, cbs: service)
        }
        markSensorActivity()
    }
    
    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        guard let service = services[characteristic.service.UUID.UUIDString] else { return }
        guard let char = service.characteristics[characteristic.UUID.UUIDString] else { return }
        if char.cbCharacteristic !== characteristic {
            char.cbCharacteristic = characteristic
        }
        char.valueUpdated()
        markSensorActivity()
    }
    
    public func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        guard let service = services[characteristic.service.UUID.UUIDString] else { return }
        guard let char = service.characteristics[characteristic.UUID.UUIDString] else { return }
        if char.cbCharacteristic !== characteristic {
            char.cbCharacteristic = characteristic
        }
        char.valueWritten()
        markSensorActivity()
    }
    
    public func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        if RSSI.integerValue < 0 {
            rssi = RSSI.integerValue
            markSensorActivity()
        }
    }
    
}

