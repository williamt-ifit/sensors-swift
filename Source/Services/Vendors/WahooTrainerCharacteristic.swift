//
//  WahooTrainerCharacteristic.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth

extension CyclingPowerService {
    
    //
    // Wahoo's Trainer Characteristic is not publicly documented.
    //
    // Nuances: after writing an ERG mode target watts, the trainer takes about 2 seconds for adjustments to be made.
    //      Delay all writes
    /// :nodoc:
    open class WahooTrainer: Characteristic {
        
        public static let uuid: String = "A026E005-0A7D-4AB3-97FA-F1500F9FEB8B"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? CyclingPowerService)?.wahooTrainer = self
            
            cbCharacteristic.notify(true)
            cbCharacteristic.write(Data(int8s: WahooTrainerSerializer.unlockCommand()), writeType: .withResponse)
        }
        
        private var ergWriteTimer: Timer?
        
        private var ergWriteWatts: UInt16?
        
        open func setResistanceErg(_ watts: UInt16) {
            ergWriteWatts = watts
            if ergWriteTimer == nil {
                writeErgWatts()
                ergWriteTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(WahooTrainer.writeErgWatts), userInfo: nil, repeats: true)
            }
        }
        
        @objc func writeErgWatts() {
            if let watts = ergWriteWatts {
                // crashing?
                cbCharacteristic.write(Data(int8s: WahooTrainerSerializer.setResistanceModeErg(watts)), writeType: .withResponse)
                ergWriteWatts = nil
            } else {
                ergWriteTimer?.invalidate()
                ergWriteTimer = nil
            }
        }
        
        open func setResistanceLevel(_ level: UInt8) {
            ergWriteTimer?.invalidate()
            ergWriteTimer = nil
            
            cbCharacteristic.write(Data(int8s: WahooTrainerSerializer.setResistanceModeLevel(level)), writeType: .withResponse)
        }
        
        override open func valueUpdated() {
            // generate response ...
            super.valueUpdated()
        }
        
    }
    
}
