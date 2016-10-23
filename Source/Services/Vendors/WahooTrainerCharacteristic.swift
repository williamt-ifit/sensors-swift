//
//  WahooTrainerCharacteristic.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import CoreBluetooth

extension CyclingPowerService {
    
    //
    // Wahoo's Trainer Characteristic is not publicly documented.
    //
    // Nuances: after writing an ERG mode target watts, the trainer takes about 2 seconds for adjustments to be made.
    //      Delay all writes
    public class WahooTrainer: Characteristic {
        static public let uuid: String = "A026E005-0A7D-4AB3-97FA-F1500F9FEB8B"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            (service as? CyclingPowerService)?.wahooTrainer = self
            
            cbCharacteristic.notify(true)
            cbCharacteristic.write(NSData.fromIntArray(WahooTrainerSerializer.unlockCommand()), writeType: .WithResponse)
        }
        
        
        private var ergWriteTimer: NSTimer?
        private var ergWriteWatts: UInt16?
        public func setResistanceErg(watts: UInt16) {
            ergWriteWatts = watts
            if ergWriteTimer == nil {
                writeErgWatts()
                ergWriteTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(WahooTrainer.writeErgWatts), userInfo: nil, repeats: true)
            }
        }
        
        @objc func writeErgWatts() {
            if let watts = ergWriteWatts {
                // crashing?
                cbCharacteristic.write(NSData.fromIntArray(WahooTrainerSerializer.setResistanceModeErg(watts)), writeType: .WithResponse)
                ergWriteWatts = nil
            } else {
                ergWriteTimer?.invalidate()
                ergWriteTimer = nil
            }
        }
        
        public func setResistanceLevel(level: UInt8) {
            ergWriteTimer?.invalidate()
            ergWriteTimer = nil
            
            cbCharacteristic.write(NSData.fromIntArray(WahooTrainerSerializer.setResistanceModeLevel(level)), writeType: .WithResponse)
        }
        
        override public func valueUpdated() {
            // generate response ...
            
            super.valueUpdated()
        }
        
    }
    
}
